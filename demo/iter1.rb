require 'paxos-demo'

include PaxosDemo

net = Network.new('iter1')
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
  reg[:proposal] = Random.rand(3)
  coords.each { |coord|
    client.send(reg[:proposal], coord)
  }
}

coords.each { |coord|
  vote = coord.process_msgs
  puts "#{coord} decided on #{vote}"
  client_registry.each { |client, reg|
    reg[:responses] ||= {}
    received = coord.send(vote, client)
    reg[:responses][received] ||= 0
    reg[:responses][received] += 1
  }
}

client_registry.each { |client, reg|
  maj = PaxosDemo.reduce(reg[:responses])
  puts "#{client} has: #{reg[:responses]}; majority: #{maj}"
  reg[:majority] = maj
}
