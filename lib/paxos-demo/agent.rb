module PaxosDemo
  class Agent
    attr_reader :name, :messages
    attr_accessor :failure_rate, :log

    def initialize(name, failure_rate: 0.0, log: true)
      @name = name.to_s
      @failure_rate = failure_rate
      @log = log
      @messages = {}
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
      @messages[from] ||= []
      @messages[from] << msg
      msg
    end

    def to_s
      @name
    end
  end
end
