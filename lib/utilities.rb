class Logger
  def format_message(severity, timestamp, progname, msg)
    "#{timestamp} (#{$$}) #{msg}\n"
  end
end

module Utilities
  
  def input_file(file_path)
    file_path.split('/').last
  end

  def logger
    @logger ||= Logger.new("/pipeline/pipeline.log")
  end

end