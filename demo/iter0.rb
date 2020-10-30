require 'paxos-demo'

include PaxosDemo

net = Network.new('iter0')

proposal = 3
alt_proposal = 4

coord = Coordinator.new('Coordinator', net)
alice = Client.new('Alice', net)
bob = Client.new('Bob', net)
charlie = Client.new('Charlie', net)

alice.send(proposal, coord)
bob.send(proposal, coord)
charlie.send(alt_proposal, coord)

consensus = coord.process_msgs
puts "Coordinator decided on #{consensus}"

alice_val = coord.send(consensus, alice)
bob_val = coord.send(consensus, bob)
charlie_val = coord.send(consensus, charlie)

puts "Checking consensus..."
puts "  Alice has: #{alice_val}"
puts "    Bob has: #{bob_val}"
puts "Charlie has: #{charlie_val}"

puts "Agreement: #{PaxosDemo.agreement?(alice_val, bob_val, charlie_val)}"


puts
failure_rate = 0.3
puts "=" * 40
puts "Now adding network failures (#{failure_rate * 100}%)"
puts "=" * 40
puts


net = Network.new('iter0', failure_rate: failure_rate)

proposal = 3
alt_proposal = 4

coord = Coordinator.new('Coordinator', net)
alice = Client.new('Alice', net)
bob = Client.new('Bob', net)
charlie = Client.new('Charlie', net)

alice.send(proposal, coord)
bob.send(proposal, coord)
charlie.send(alt_proposal, coord)

consensus = coord.process_msgs
puts "Coordinator decided on #{consensus}"

alice_val = coord.send(consensus, alice)
bob_val = coord.send(consensus, bob)
charlie_val = coord.send(consensus, charlie)

puts "Checking consensus..."
puts "  Alice has: #{alice_val}"
puts "    Bob has: #{bob_val}"
puts "Charlie has: #{charlie_val}"

puts "Agreement: #{PaxosDemo.agreement?(alice_val, bob_val, charlie_val)}"



puts
failure_rate = 0.3
puts "=" * 40
puts "Now substituting Coordinator failures (#{failure_rate * 100}%)"
puts "=" * 40
puts


net = Network.new('iter0')

proposal = 3
alt_proposal = 4

coord = Coordinator.new('Coordinator',
                        net,
                        failure_rate: failure_rate,
                        log: true)
alice = Client.new('Alice', net)
bob = Client.new('Bob', net)
charlie = Client.new('Charlie', net)

alice.send(proposal, coord)
bob.send(proposal, coord)
charlie.send(alt_proposal, coord)

consensus = coord.process_msgs
puts "Coordinator decided on #{consensus}"

alice_val = coord.send(consensus, alice)
bob_val = coord.send(consensus, bob)
charlie_val = coord.send(consensus, charlie)

puts "Checking consensus..."
puts "  Alice has: #{alice_val}"
puts "    Bob has: #{bob_val}"
puts "Charlie has: #{charlie_val}"

puts "Agreement: #{PaxosDemo.agreement?(alice_val, bob_val, charlie_val)}"
