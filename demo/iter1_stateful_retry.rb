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
  clients = [
    StatefulClient.new('Alice', net),
    StatefulClient.new('Bob', net),
    StatefulClient.new('Charlie', net),
    StatefulClient.new('David', net),
    StatefulClient.new('Emma', net),
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
