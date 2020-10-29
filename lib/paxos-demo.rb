module PaxosDemo
  class Client
    FAILURE_RATE = 0.0

    def initialize(name, network)
      @name = name
      @network = network
    end

    def send(msg, to)
      @network.deliver(msg, self, to)
    end

    def receive(msg, from)
      puts "#{@name} received #{msg} from #{from}"
      msg
    end

    def to_s
      @name
    end
  end

  class Network
    FAILURE_RATE = 0.0

    def initialize(name)
      @name = name
    end

    def deliver(msg, from, to)
      if Random.rand > self.class::FAILURE_RATE
        puts "[#{@name}] #{from} -> #{to}: #{msg} - SUCCESS"
        to.receive(msg, from)
      else
        puts "[#{@name}] #{from} -> #{to}: #{msg} - FAILURE"
      end
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

  class UnreliableClient < Client
    FAILURE_RATE = 0.1
  end

  class UnreliableNetwork < Client
    FAILURE_RATE = 0.1
  end
end
