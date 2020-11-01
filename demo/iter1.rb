require 'paxos-demo'

include PaxosDemo

[0.0, 0.2, 0.4].each { |failure_rate|
  puts "=" * 40
  puts "Network failure rate: #{failure_rate}"
  puts "=" * 40

  net = Network.new('iter1', failure_rate: failure_rate)
  coords = [
    Coordinator.new('coord0', net),
    Coordinator.new('coord1', net),
    Coordinator.new('coord2', net),
  ]

  client_registry = {
    Client.new('Alice', net) => {},
    Client.new('Bob', net) => {},
    Client.new('Charlie', net) => {},
    Client.new('David', net) => {},
    Client.new('Emma', net) => {},
  }

  client_registry.each { |client, reg|
    reg[:proposal] = Random.rand(client_registry.keys.length)
    coords.each { |coord|
      client.send(reg[:proposal], coord)
    }
  }

  coords.each { |coord|
    puts "#{coord} has: #{coord.msgs}"
    vote = coord.process_msgs
    puts "#{coord} decided on #{vote}"
    client_registry.each { |client, reg|
      reg[:responses] ||= {}
      received = coord.send(vote, client)
      if received
        reg[:responses][received] ||= 0
        reg[:responses][received] += 1
      end
    }
  }

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
