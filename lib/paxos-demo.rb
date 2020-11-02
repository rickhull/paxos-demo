require 'set'

module PaxosDemo
  # if all args are the same, return that arg, otherwise nil
  #
  def self.agreement?(*args)
    args[0] if args.all? args[0]
  end

  # reduce a hash of mesg => count down to the most numerous message
  #
  def self.reduce(msg_counts)
    mesg = nil
    count = 0
    msg_counts.each { |msg, cnt|
      if cnt > count
        mesg = msg
        count = cnt
      end
    }
    mesg
  end

  class Network
    def initialize(name, failure_rate: 0.0, log: true)
      @name = name
      @failure_rate = failure_rate
      @log = log
    end

    def deliver(msg, from, to)
      if Random.rand > @failure_rate
        puts "[#{@name}] #{from} -> #{to}: #{msg} [OK]" if @log
        to.receive(msg, from)
      else
        puts "[#{@name}] #{from} -> #{to}: #{msg} [FAIL]" if @log
      end
    end
  end

  class Client
    def initialize(name, network, failure_rate: 0.0, log: false)
      @name = name
      @network = network
      @failure_rate = failure_rate
      @log = log
    end

    def send(msg, to)
      if Random.rand > @failure_rate
        @network.deliver(msg, self, to)
      else
        puts "send failed: #{self} -> #{to}: #{msg}" if @log
      end
    end

    def receive(msg, from)
      msg
    end

    def to_s
      @name
    end
  end

  class Coordinator < Client
    attr_reader :msgs, :clients, :choice

    def initialize(*args)
      @msgs = {}
      @clients = Set.new
      @choice = nil
      super(*args)
    end

    def receive(msg, from)
      @clients << from
      @msgs[msg] ||= 0
      @msgs[msg] += 1
      super(msg, from)
    end

    def process_msgs!
      raise "@choice already made" if @choice
      @choice = PaxosDemo.reduce(@msgs)
      @msgs = {}
      @choice
    end

    def respond(to)
      raise "no @choice" unless @choice
      self.send(@choice, to)
    end
  end
end
