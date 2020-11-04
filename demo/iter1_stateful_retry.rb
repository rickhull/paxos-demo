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
  clients = [
    StatefulAgent.new('Alice', failure_rate: fr),
    StatefulAgent.new('Bob', failure_rate: fr),
    StatefulAgent.new('Charlie', failure_rate: fr),
    StatefulAgent.new('David', failure_rate: fr),
    StatefulAgent.new('Emma', failure_rate: fr),
  ]

  # each client sends a random proposal to each coordinator
  clients.each { |client|
    client.proposal = Random.rand(clients.length)
    coords.each { |coord|
      # note: client doesn't yet know if the proposal was received
      client.propose(coord)
    }
  }

  coords.each { |coord|
    # each coordinator selects the most popular proposal
    puts "#{coord} has: #{coord.msgs}"
    coord.process_msgs!
    puts "#{coord} decided on #{coord.choice}"

    # each coordinator responds to clients it has heard from
    coord.clients.each { |client|
      coord.respond(client)
    }
  }

  # keep retrying proposals until all coordinators have responded
  clients.each { |client|
    # stateful client knows which coordinators have responded
    client.coordinators.each { |coord, resp|
      next if resp
      puts "=== RETRY ==="
      while !resp
        # coordinator can only respond if the proposal is delivered
        if client.propose(coord)
          resp = coord.respond(client)
        end
      end
    }
  }

  begin
    majorities = []
    clients.each { |client|
      majorities << client.majority
      puts "#{client}: #{majorities.last} #{client.coordinators.values}"
    }

    puts ["Agreement", PaxosDemo.agreement?(*majorities) || 'FAILED'
         ].join(': ')
    puts
  rescue RuntimeError => e
    puts e.message
    puts "FAILED"
    puts
  end
}
