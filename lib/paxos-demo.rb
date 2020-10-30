module PaxosDemo
  def self.agreement?(*args)
    args.all? args[0]
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

    def initialize(*args)
      @msgs = {}
      super(*args)
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
