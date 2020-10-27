require 'paxos-demo'

net = PaxosDemo::Network.new('test')

alice = PaxosDemo::Client.new('Alice', net)
bob = PaxosDemo::Client.new('Bob', net)

alice.send(5, bob)
bob.send(10, alice)

