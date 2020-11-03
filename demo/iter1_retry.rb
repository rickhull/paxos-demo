require 'paxos-demo/iterations'

include PaxosDemo

[0.0, 0.2, 0.4].each { |failure_rate|
  puts "=" * 40
  puts "Network failure rate: #{failure_rate}"
  puts "=" * 40

  # create a Network
  net = Network.new('iter1', failure_rate: failure_rate)

  # create 3 Coordinators
  coords = [
    Coordinator.new('coord0', net),
    Coordinator.new('coord1', net),
    Coordinator.new('coord2', net),
  ]

  # create 5 Clients with an associated structure for what they 'see'
  client_registry = {
    Client.new('Alice', net) => {},
    Client.new('Bob', net) => {},
    Client.new('Charlie', net) => {},
    Client.new('David', net) => {},
    Client.new('Emma', net) => {},
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
