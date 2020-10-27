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

  class UnreliableClient
    FAILURE_RATE = 0.1
  end

  class UnreliableNetwork
    FAILURE_RATE = 0.1
  end
end
