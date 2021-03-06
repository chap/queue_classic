module QC
  class Worker

    def initialize
      @running = true
      @queue = QC::Queue.new(ENV["QUEUE"])
      handle_signals
    end

    def running?
      @running
    end

    def handle_signals
      %W(INT TRAP).each do |sig|
        trap(sig) do
          if running?
            @running = false
          else
            raise Interrupt
          end
        end
      end
    end

    def start
      while running? do
        work
      end
    end

    def work
      if job = @queue.dequeue #blocks until we have a job
        begin
          job.work
        rescue Object => e
          handle_failure(job,e)
        ensure
          @queue.delete(job)
        end
      end
    end

    #override this method to do whatever you want
    def handle_failure(job,e)
      puts "!"
      puts "! \t FAIL"
      puts "! \t \t #{job.inspect}"
      puts "! \t \t #{e.inspect}"
      puts "!"
    end

  end
end
