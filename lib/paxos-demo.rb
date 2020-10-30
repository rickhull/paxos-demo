module PaxosDemo
  def self.agreement?(*args)
    args.all? args[0]
  end

  class Network
    LOG = true

    def initialize(name, failure_rate: 0.0)
      @name = name
      @failure_rate = failure_rate
    end

    def deliver(msg, from, to)
      if Random.rand > @failure_rate
        puts "[#{@name}] #{from} -> #{to}: #{msg} [OK]" if LOG
        to.receive(msg, from)
      else
        puts "[#{@name}] #{from} -> #{to}: #{msg} [FAIL]" if LOG
      end
    end
  end

  class Client
    def initialize(name, network, failure_rate: 0.0)
      @name = name
      @network = network
      @failure_rate = failure_rate
    end

    def send(msg, to)
      @network.deliver(msg, self, to) if Random.rand > @failure_rate
    end

    def receive(msg, from)
      msg
    end

    def to_s
      @name
    end
  end

  class Coordinator < Client
    def self.process(msgs)
      mesg = nil
      count = 0
      msgs.each { |msg, cnt|
        if cnt > count
          mesg = msg
          count = cnt
        end
      }
      mesg
    end

    attr_reader :msgs

    def initialize(name, network)
      @msgs = {}
      super(name, network)
    end

    def receive(msg, from)
      @msgs[msg] ||= 0
      @msgs[msg] += 1
      super(msg, from)
    end

    def process_msgs
      maj = self.class.process(@msgs)
      @msgs = {}
      maj
    end
  end
end
