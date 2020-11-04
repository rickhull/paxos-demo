module PaxosDemo
  class Agent
    def initialize(name, failure_rate: 0.0, log: true)
      @name = name.to_s
      @failure_rate = failure_rate
      @log = log
    end

    def send(msg, to)
      if Random.rand > @failure_rate
        puts "#{@name} -> #{other}: #{msg} [OK]" if @log
        to.receive(msg, self)
      else
        puts "#{@name} -> #{other}: #{msg} [FAIL]" if @log
      end
    end

    def receive(msg, from)
      # just a hook for now?
      msg
    end

    def to_s
      @name
    end
  end
end
