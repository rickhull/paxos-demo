require 'paxos-demo'
require 'minitest/autorun'

include PaxosDemo

describe PaxosDemo do
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
  end

  describe "PaxosDemo.reduce" do
    it "must determine the majority message" do
      expect(PaxosDemo.reduce(@clear)).must_equal(:alice)
      expect(PaxosDemo.reduce(@reverse)).must_equal(:david)
      25.times {
        unc = PaxosDemo.reduce(@unclear)
        expect(unc).wont_equal(:david)
        expect([:alice, :bob, :charlie]).must_include(unc)
        ted = PaxosDemo.reduce(@tied)
        expect(ted).wont_equal(:david)
        expect([:alice, :bob, :charlie]).must_include(ted)
      }
      expect(PaxosDemo.reduce(@empty)).must_be_nil
    end
  end

  describe "PaxosDemo.agreement?" do
    it "must determine if all arguments are the same" do
      expect(PaxosDemo.agreement?(1, 2, 3)).must_be_nil
      expect(PaxosDemo.agreement?(1, 1, 3)).must_be_nil
      expect(PaxosDemo.agreement?(1, 1, 1)).must_equal 1
    end
  end

  describe Coordinator do
    before do
      @net = Network.new('test', log: false)
      @coord = Coordinator.new('test', @net)
      @client = Client.new('test', @net)
      @clear.each { |msg, cnt|
        cnt.times { @client.send(msg, @coord) }
      }
    end

    it "must accumulate messages in a Hash" do
      expect(@coord.msgs).must_equal @clear
    end

    it "must not have a choice until process_msgs!" do
      expect(@coord.choice).must_be_nil
      @coord.process_msgs!
      expect(@coord.choice).must_equal :alice
    end

    it "must not make a new choice" do
      expect(@coord.choice).must_be_nil
      @coord.process_msgs!
      expect(@coord.choice).must_equal :alice
      @reverse.each { |msg, cnt|
        cnt.times { @client.send(msg, @coord) }
      }
      expect(@coord.msgs).must_equal @reverse
      expect { @coord.process_msgs! }.must_raise RuntimeError
    end
  end
end
