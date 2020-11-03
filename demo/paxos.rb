require 'paxos-demo/paxos'

include PaxosDemo

num_proposers = 5
num_acceptors = 5
proposals = [:alpha, :bravo, :charlie, :delta, :echo]

proposers = Array.new(num_proposers) {
  Proposer.new(value: proposals.sample)
}

acceptors = Array.new(num_acceptors) {
  Acceptor.new
}

proposers.each { |p|
  # attempt a prepare message to each known Acceptor
  acceptors.each { |a|
    msg = p.prepare
    response = a.response(msg)
    if response
      puts "response: #{response}"
      if response.prepare?
        msg = p.proposal
        puts "proposer proposes #{msg.value}"
        response = a.response(msg)
        if response
          puts "proposal accepted"
        end
      end
    end
  }
}
