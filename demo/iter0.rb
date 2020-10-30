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

coord.send(consensus, alice)
coord.send(consensus, bob)
coord.send(consensus, charlie)
