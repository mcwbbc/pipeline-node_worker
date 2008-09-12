class Packer

  include Utilities
  
  attr_accessor :message

  def initialize(message)
    self.message = message
  end

  def run
    begin
      make_directory
      download_files
      zip_files
      send_file(local_zipfile) # this will upload and send the messages, since we can have other nodes start on them
      send_job_message
    end
    ensure
      cleanup_pack
  end

  def manifest
    @manifest ||= YAML.load(AWS.s3i.get_object(BUCKET_NAME, "#{message[:job_id]}/manifest.yml"))
  end

  def download_files
    manifest.each do |file|
      foo = File.new("#{PACK_DIR}/"+input_file(file), File::CREAT|File::RDWR)
      hash = AWS.s3i.get(BUCKET_NAME, file) do |chunk|
        foo.write(chunk)
      end
      foo.close
    end
  end

  def cleanup_pack
    FileUtils.rm_r(PACK_DIR) if File.exists?(PACK_DIR)
  end
  
  def local_zipfile
    "#{PACK_DIR}/"+message[:output_file]
  end

  def zip_files
    Zip::ZipFile.open(local_zipfile, Zip::ZipFile::CREATE) { |zipfile|
      output_filenames.each do |filename|
        zipfile.add(input_file(filename), filename)
      end
    }
  end
  
  def make_directory
    target = PACK_DIR
    begin
      Dir.mkdir(target) unless File.exists?(target)
    end
  end

  def send_job_message
    hash = {:type => DOWNLOAD, :job_id => message[:job_id], :bucket_name => BUCKET_NAME}
    logger.debug {"Sending HEAD message: #{hash.to_yaml}"}
    head_success = AWS.send_head_message(hash.to_yaml) unless DEBUG
    hash[:type] = FINSHED
    finished_success = AWS.send_finished_message(hash.to_yaml) unless DEBUG
  end

  def send_file(file)
    success = AWS.put_object(bucket_object(file), File.open(file), {"x-amz-acl" => "public-read"}) unless DEBUG
    DEBUG ? true : success
  end

  def bucket_object(file_path)
    "completed-jobs/"+input_file(file_path)
  end

  def output_filenames
    # Review the contents of the directory, listing number of .mgf files that were found
    @output_filenames ||= Dir["#{PACK_DIR}/*.{xml,csv,conf}"]
  end

end
