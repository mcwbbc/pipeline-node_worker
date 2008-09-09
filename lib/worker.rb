class Worker
  
  include Utilities
  
  attr_accessor :message
  
  def initialize(message)
    self.message = message
  end

  def run
    begin
      make_tmp
      case message[:type]
        when PACK
          packer = Packer.new(message)
          packer.run
        when UNPACK
          unpacker = Unpacker.new(message)
          unpacker.run
        when PROCESS
          @starttime = Time.now.to_f
          @finishtime = 0
          download_file(local_input_filename, message[:filename])
          download_file(local_parameter_filename, message[:parameter_filename])
          send_message(START)
          process_file
          until upload_output_file
            logger.debug { "There was a problem uploading #{message[:filename]}" }
          end
          @finishtime = Time.now.to_f
          send_message(FINISH)
      end
    end
    ensure
      cleanup_tmp
  end
  
  # make the temporary directory for this process id
  def make_tmp
    begin
      Dir.mkdir(PIPELINE_TMP)
    end
    rescue Exception => e
      logger.error {"#{e.inspect}"}
      logger.error {"#{e.backtrace.join('\n')}"}
  end
  
  # remove the temporary directory for this process id
  def cleanup_tmp
    begin
      FileUtils.rm_r(PIPELINE_TMP) if File.exists?(PIPELINE_TMP)
    end
    rescue Exception => e
      logger.error {"#{e.inspect}"}
      logger.error {"#{e.backtrace.join('\n')}"}
  end

  def process_file
    searcher = nil
    case message[:searcher]
      when "omssa"
        searcher = Omssa.new(local_parameter_filename, local_input_filename, local_output_filename)
      when "tandem"
        searcher = Tandem.new(local_parameter_filename, local_input_filename, local_output_filename)
    end
    searcher.run
  end

  def upload_output_file
    logger.debug {"Passing output file back up to S3: #{message[:job_id]}/out/#{input_file(local_output_filename)} @ #{Time.now()}"}
    AWS.put_object("#{message[:job_id]}/out/params.conf", File.open(local_parameter_filename)) # add the conf file to the output
    AWS.put_object("#{message[:job_id]}/out/"+input_file(local_output_filename), File.open(local_output_filename))
  end

  def send_message(type)
    # TODO: send file complete message
    hash = {:type => type, :bytes => message[:bytes], :filename => message[:filename], :parameter_filename => message[:parameter_filename], :sendtime => message[:sendtime], :chunk_key => message[:chunk_key], :job_id => message[:job_id], :instance_id => "#{INSTANCE_ID}-#{$$}", :starttime => @starttime, :finishtime => @finishtime}
    logger.debug {"Sending message: #{hash.to_yaml}"}
    AWS.send_head_message(hash.to_yaml)
  end

  def download_file(local, remote)
    foo = File.new(local, File::CREAT|File::RDWR)
    hash = AWS.s3i.get(BUCKET_NAME, remote) do |chunk|
      foo.write(chunk)
    end
    foo.close
    hash
  end
  
  def local_output_filename
    case message[:searcher]
      when "omssa"
        local_input_filename+"-out.csv"
      when "tandem"
        local_input_filename+"-out.xml"
    end
  end

  def local_input_filename
    "#{PIPELINE_TMP}/"+input_file(message[:filename])
  end

  def local_parameter_filename
    "#{PIPELINE_TMP}/"+input_file(message[:parameter_filename])
  end
  
end
