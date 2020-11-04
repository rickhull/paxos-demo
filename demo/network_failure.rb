require 'paxos-demo/agent'

include PaxosDemo

alice = Agent.new('Alice')
bob = Agent.new('Bob')

alice.send(5, bob)
bob.send(10, alice)
