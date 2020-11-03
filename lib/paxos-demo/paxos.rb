module PaxosDemo
  class Proposer
    class ProposalError < RuntimeError; end

    attr_reader :number, :value

    def initialize(number: 0, value:)
      @number = number
      @value = value
    end

    def prepare
      Message.new(number: @number)
    end

    # aka an _accept_ request
    def proposal(value = @value)
      raise(ProposalError, "value must not be nil") if value.nil?
      @value ||= value
      if @value != value
        @value = value
        @number += 1
      end
      Message.new(number: @number, value: @value)
    end

    # if an acceptor responds with higher-numbered proposal, we need to adopt
    def adopt!(proposal)
      @number = proposal.number
      @value = proposal.value
    end
  end

  class Message
    PREPARE_MAGIC_VALUE = :prepare

    attr_reader :number, :value

    def initialize(number: 0, value: PREPARE_MAGIC_VALUE)
      @number = number
      @value = value
    end

    def prepare?
      @value == PREPARE_MAGIC_VALUE
    end

    def to_s
      [@number, @value].join(':')
    end
  end

  class Acceptor
    attr_reader :prepare, :proposal

    def initialize(prepare: nil, proposal: nil)
      @prepare = prepare
      @proposal = proposal
    end

    def response(request)
      if request.prepare?
        if @prepare.nil? or request.number > @prepare.number
          puts "got a positive prepare request"
          @prepare = request
          return @proposal ? @proposal : @prepare
        else
          puts "got a negative prepare request"
          # don't respond, or respond negatively
        end
      else # this is a proposal
        if @prepare.nil?
          puts "got a proposal but haven't seen any prepares yet"
          # this is probably an error
        elsif request.number >= @prepare.number
          puts "got a positive proposal"
          @proposal = request
          return @proposal
        else
          puts "got a negative proposal"
          # don't respond, or respond negatively
        end
      end
    end
  end
end
