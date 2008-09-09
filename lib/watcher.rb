class Watcher

  include Utilities

  def run
    loop do
      # If we have jobs on the queue
      message = AWS.node_queue.receive(300) # we have two minutes to process this message, or it goes back on the queue
      if message
        logger.debug {"Message info: #{message.body}"}
        # Sometimes it gets a job but its empty (another script has taken the job in the meantime?),
        # this if statement is a simple fix to stop these cases from crashing the script
        if message.body.blank?
          message.delete #delete it if it's blank... might cause issues
        else
          hash = YAML.load(message.body)
          worker = Worker.new(hash)
          begin
            message.delete if worker.run
          rescue RightAws::AwsError => e
            logger.error { e.inspect }
            message.delete if e.message =~ /NoSuchKey/
          end
        end
      end
    end
  end
  
end

