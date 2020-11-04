require 'paxos-demo/iterations'

include PaxosDemo

[0.0, 0.2, 0.4].each { |fr|
  puts "=" * 40
  puts "Network failure rate: #{fr}"
  puts "=" * 40

  # create 3 Coordinators
  coords = [
    Coordinator.new('coord0', failure_rate: fr),
    Coordinator.new('coord1', failure_rate: fr),
    Coordinator.new('coord2', failure_rate: fr),
  ]

  # create 5 Agents with an associated structure for what they 'see'
  client_registry = {
    Agent.new('Alice', failure_rate: fr) => {},
    Agent.new('Bob', failure_rate: fr) => {},
    Agent.new('Charlie', failure_rate: fr) => {},
    Agent.new('David', failure_rate: fr) => {},
    Agent.new('Emma', failure_rate: fr) => {},
  }

  # each client sends a random proposal to the coordinator
  client_registry.each { |client, reg|
    # proposal space matches client count
    reg[:proposal] = Random.rand(client_registry.keys.length)
    coords.each { |coord|
      client.send(reg[:proposal], coord)
    }
    # create a structure to hold coordinator responses
    reg[:responses] = {}

    # create a structure to track which coordinators have responded
    reg[:coordinators] = []
  }

  coords.each { |coord|
    # each coordinator selects the most popular proposal
    puts "#{coord} has: #{coord.msgs}"
    coord.process_msgs!
    puts "#{coord} decided on #{coord.choice}"

    # each coordinator responds to clients it has heard from
    coord.clients.each { |client|
      reg = client_registry[client]
      received = coord.respond(client)
      if received
        reg[:responses][received] ||= 0
        reg[:responses][received] += 1
        reg[:coordinators] << coord
      end
    }
  }

  # keep retrying proposals until all coordinators have responded
  client_registry.each { |client, reg|
    remaining = coords - reg[:coordinators]
    while !remaining.empty?
      puts "=== RETRY ==="
      remaining.each { |coord|
        if client.send(reg[:proposal], coord)
          received = coord.respond(client)
          if received
            reg[:responses][received] ||= 0
            reg[:responses][received] += 1
            reg[:coordinators] << coord
          end
        end
      }
      remaining = coords - reg[:coordinators]
    end
  }

  # determine the most popular (majority?) response from the coordinators
  client_registry.each { |client, reg|
    maj = PaxosDemo.reduce(reg[:responses])
    puts "#{client} has: #{reg[:responses]}; majority: #{maj}"
    reg[:majority] = maj
  }

  agreed =
    PaxosDemo.agreement?(*client_registry.values.map { |h| h[:majority] }) ||
    'FAILED'

  puts "Agreement: #{agreed}"
  puts
}
