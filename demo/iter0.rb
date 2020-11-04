require 'paxos-demo/iterations'

include PaxosDemo

[0.0, 0.2, 0.4].each { |fr|
  puts "=" * 40
  puts "Network failure rate: #{fr}"
  puts "=" * 40

  # create a Coordinator
  coord = Coordinator.new('Coordinator', failure_rate: fr)

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
    client.send(reg[:proposal], coord)
  }

  # coordinator selects the most popular proposal
  puts "#{coord} has: #{coord.msgs}"
  coord.process_msgs!
  puts "#{coord} decided on #{coord.choice}"

  # The coordinator can only respond to messages it has received
  # We don't want to iterate over the full client list, only the clients
  # that the coordinator has heard from
  coord.clients.each { |client|
    # note, this delivery may fail, and the client registry will have nil
    client_registry[client][:response] = coord.send(coord.choice, client)
  }

  agreed =
    PaxosDemo.agreement?(*client_registry.values.map { |h| h[:response] }) ||
    'FAILED'

  puts "Agreement: #{agreed}"
  puts
}
