require 'paxos-demo'
require 'minitest/autorun'

include PaxosDemo

describe Coordinator do
  before do
    @clear = {
      alice: 35,
      bob: 32,
      charlie: 30,
      david: 5
    }

    @unclear = {
      alice: 35,
      bob: 35,
      charlie: 35,
      david: 30,
    }

    @reverse = {
      alice: 5,
      bob: 30,
      charlie: 32,
      david: 35,
    }

    @tied = {
      alice: 2,
      bob: 2,
      charlie: 2,
    }

    @empty = {}

    @net = Network.new('test', log: false)
    @hc = Coordinator.new('test', @net)
    @client = Client.new('test', @net)
  end

  it "must determine the majority message" do
    expect(Coordinator.process(@clear)).must_equal(:alice)
    expect(Coordinator.process(@reverse)).must_equal(:david)
    25.times {
      unc = Coordinator.process(@unclear)
      expect(unc).wont_equal(:david)
      expect([:alice, :bob, :charlie]).must_include(unc)
      ted = Coordinator.process(@tied)
      expect(ted).wont_equal(:david)
      expect([:alice, :bob, :charlie]).must_include(ted)
    }
    expect(Coordinator.process(@empty)).must_be_nil
  end

  it "must accumulate messages in a Hash" do
    @clear.each { |msg, cnt|
      cnt.times { @client.send(msg, @hc) }
    }
    expect(@hc.msgs).must_equal @clear
    expect(@hc.process_msgs).must_equal :alice

    @reverse.each { |msg, cnt|
      cnt.times { @client.send(msg, @hc) }
    }
    expect(@hc.msgs).must_equal @reverse
    expect(@hc.process_msgs).must_equal :david
  end
end
