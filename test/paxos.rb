require 'paxos-demo/paxos'
require 'minitest/autorun'

include PaxosDemo

describe Message do
  before do
    @prepare = Message.new
    @proposal = Message.new(value: :foo)
  end

  it "defaults to a special _prepare_ message" do
    expect(@prepare.number).must_equal 0
    expect(@prepare.value).must_equal Message::PREPARE_MAGIC_VALUE
    expect(@prepare.prepare?).must_equal true
    expect(@proposal.prepare?).wont_equal true
  end

  it "has a number and a value" do
    expect(@proposal.number).must_equal 0
    expect(@proposal.value).must_equal :foo

    m = Message.new(number: 17, value: :bar)
    expect(m.number).must_equal 17
    expect(m.value).must_equal :bar
  end
end

describe Proposer do
  before do
    @p = Proposer.new(value: nil)
    @q = Proposer.new(value: :initial_value)
  end

  it "creates a _prepare_ message" do
    msg = @p.prepare
    expect(msg.number).must_equal 0
    expect(msg.value).must_equal Message::PREPARE_MAGIC_VALUE
    expect(msg.prepare?).must_equal true
  end

  it "creates a proposal message" do
    msg = @p.proposal(:foo)
    expect(msg.number).must_equal 0
    expect(msg.value).must_equal :foo
    expect(msg.prepare?).must_equal false
  end

  it "won't create a proposal with nil value" do
    expect { @p.proposal }.must_raise Proposer::ProposalError
    expect { @q.proposal(nil) }.must_raise Proposer::ProposalError
  end

  it "remembers its highest number and most recent value" do
    msg = @p.proposal(:foo)
    expect(@p.number).must_equal msg.number
    expect(@p.value).must_equal msg.value
    new_msg = @p.proposal
    expect(new_msg).wont_equal msg
    expect(new_msg.number).must_equal msg.number
    expect(new_msg.value).must_equal msg.value
  end

  it "creates a higher-numbered proposal for a new value" do
    msg = @p.proposal(:foo)
    new_msg = @p.proposal(:bar)
    expect(new_msg).wont_equal msg
    expect(new_msg.number).must_be(:>, msg.number)
    expect(new_msg.number).must_equal 1
    expect(new_msg.value).wont_equal msg.value
    expect(new_msg.value).must_equal :bar
    expect(@p.number).must_equal 1
    expect(@p.value).must_equal :bar
  end

  it "adopts an already-accepted proposal" do
    other_proposal = Message.new(number: 27, value: :baz)
    @p.adopt!(other_proposal)
    msg = @p.proposal
    expect(msg).wont_equal other_proposal
    expect(msg.number).must_equal other_proposal.number
    expect(msg.value).must_equal other_proposal.value

    new_msg = @p.proposal(:quux)
    expect(new_msg.number).must_be(:>, msg.number)
    expect(new_msg.value).wont_equal msg.value
    expect(new_msg.value).must_equal :quux
  end
end
