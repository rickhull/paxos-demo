require 'paxos-demo'
require 'minitest/autorun'

include PaxosDemo

describe Coordinator do
  it "must find the most common member of an array" do
    def create_ary(hsh)
      ary = []
      hsh.each { |k,v|
        v.times { ary << k }
      }
      ary
    end
    
    clear = create_ary({
                         alice: 35,
                         bob: 32,
                         charlie: 30,
                         david: 5,
                       })

    unclear = create_ary({
                           alice: 35,
                           bob: 35,
                           charlie: 35,
                           david: 30,
                         })

    reverse = create_ary({
                           alice: 5,
                           bob: 30,
                           charlie: 32,
                           david: 35,
                         })

    tied = create_ary({
                        alice: 2,
                        bob: 2,
                        charlie: 2,
                      })

    empty = []
    
    expect(Coordinator.process(clear)).must_equal(:alice)
    expect(Coordinator.process(reverse)).must_equal(:david)
    25.times {
      unc = Coordinator.process(unclear)
      expect(unc).wont_equal(:david)
      expect([:alice, :bob, :charlie]).must_include(unc)
      ted = Coordinator.process(tied)
      expect(ted).wont_equal(:david)
      expect([:alice, :bob, :charlie]).must_include(ted)
    }
    expect(Coordinator.process(empty)).must_be_nil
  end
end
