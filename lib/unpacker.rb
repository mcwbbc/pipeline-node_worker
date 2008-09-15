class Unpacker

  include Utilities
  
  attr_accessor :message

  def initialize(message)
    self.message = message
  end

  def run
    begin
      send_job_message(JOBUNPACKING)
      make_directory
      download_file
      unzip_file(local_zipfile, UNPACK_DIR)
      split_file
      send_file(local_parameter_file)
      upload_data # this will upload and send the messages, since we can have other nodes start on them
      send_job_message(JOBUNPACKED)
    end
    ensure
      cleanup_unpack
  end

  def cleanup_unpack
    FileUtils.rm_r(UNPACK_DIR) if File.exists?(UNPACK_DIR)
  end
  
  def local_zipfile
    "#{UNPACK_DIR}/data.zip"
  end
  
  def local_parameter_file
    "#{UNPACK_DIR}/#{PARAMETER_FILENAME}"
  end
  
  def make_directory
    target = UNPACK_DIR
    begin
      Dir.mkdir(target) unless File.exists?(target)
    end
  end

  def download_file
    foo = File.new(local_zipfile, File::CREAT|File::RDWR)
    hash = AWS.s3i.get(BUCKET_NAME, message[:datafile]) do |chunk|
      foo.write(chunk)
    end
    foo.close
    hash
  end

  def unzip_file(source, target)
    Zip::ZipFile.open(source) do |zipfile|
      dir = zipfile.dir
  
      dir.entries('.').each do |entry|
        zipfile.extract(entry, "#{target}/#{entry}")
      end
    end
  
    rescue Zip::ZipDestinationFileExistsError => ex
      nil
      # I'm going to ignore this and just overwrite the files.
  end

  def split_file
    # split the mgf file from the zip into 200 ion parts
    ions = 0
    filecount = 0
    input_name = input_file(mgf_filename).split('.').first

    mgf_dir = "#{UNPACK_DIR}/mgfs"
    FileUtils.rm_r(mgf_dir) if File.exists?(mgf_dir)
    Dir.mkdir(mgf_dir)

    text = ""
    outfile = ""
    File.open(mgf_filename).each do |line|
      filenumber = "%04d" % filecount
      outfile = "#{mgf_dir}/#{input_name}-#{filenumber}.mgf"
      text << line
      ions+=1 if line =~ /END IONS/
      if (ions == 200)
        File.open(outfile, 'w') do |out|
          out.write(text)
        end
        ions = 0
        filecount+=1
        text = ""
      end
    end
    File.open(outfile, 'w') do |out|
      out.write(text)
    end
  end

  def send_job_message(type)
    hash = {:type => type, :job_id => message[:job_id]}
    logger.debug {"Sending HEAD message: #{hash.to_yaml}"}
    head_success = AWS.send_head_message(hash.to_yaml)
  end

  def upload_data
    upload_started = Time.now()
    count = 0
    chunk_count = mgf_filenames.size
    mgf_filenames.each do |file|
      count += 1 if (send_file(file) && send_messages(file))
    end
    upload_finished = Time.now()
    took = upload_finished - upload_started
    logger.debug {"UNPACK AND UPLOAD TOOK: #{took}"}
    (count == chunk_count)
  end

  def send_file(file)
    success = AWS.put_object(bucket_object(file), File.open(file))
  end

  def send_messages(file)
    bytes = File.size(file)
    sendtime = Time.now.to_f
    chunk_key = Digest::SHA1.hexdigest("#{bucket_object(file)}--#{sendtime}")

    created = {:type => CREATED, :chunk_count => mgf_filenames.size, :bytes => bytes, :sendtime => sendtime, :chunk_key => chunk_key, :job_id => message[:job_id], :filename => bucket_object(file), :parameter_filename => bucket_object(PARAMETER_FILENAME), :bucket_name => message[:bucket_name], :searcher => message[:searcher]}
    logger.debug {"Sending HEAD message: #{created.to_yaml}"}
    AWS.send_created_chunk_message(created.to_yaml)
  end

  def bucket_object(file_path)
    "#{message[:job_id]}/"+input_file(file_path)
  end

  def mgf_filename
    # Review the contents of the directory, listing number of .mgf files that were found
    @mgf_filename ||= Dir["#{UNPACK_DIR}/*.mgf"].first
  end
  
  def mgf_filenames
    # Review the contents of the directory, listing number of .mgf files that were found
    @mgf_filenames ||= Dir["#{UNPACK_DIR}/mgfs/*.mgf"]
  end

end
  