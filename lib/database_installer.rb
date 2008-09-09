class DatabaseInstaller
    
  include Utilities
  
  def run
    manifest = get_databases
    download_databases(manifest)
    unpack_databases(manifest)
    format_databases
  end
  
  def download_databases(manifest)
    manifest.each do |file|
      if File.exists?(db_filepath(file))
        logger.debug { "File exists: #{db_filepath(file)}" }
        next
      end
      foo = File.new(db_filepath(file), File::CREAT|File::RDWR)
      hash = AWS.s3i.get(DB_BUCKET, file) do |chunk|
        foo.write(chunk)
      end
      foo.close
    end
  end

  def get_databases
    @list ||=
      begin
        AWS.s3i.incrementally_list_bucket(DB_BUCKET, { 'prefix' => "" }) do |file|
          @list = file[:contents].map {|content| content[:key] }
        end
        @list
      end
  end
  
  def format_databases
    fasta_files.each do |file|
      output = file.match(/(.+)\.fasta$/)[1]
      format_db(file, output)
    end
  end

  def unpack_databases(manifest)
    manifest.each do |file|
      unzip_file("#{DB_PATH}/"+input_file(file))
    end
  end

  def unzip_file(source)
    Zip::ZipFile.open(source) do |zipfile|
      dir = zipfile.dir
      dir.entries('.').each do |entry|
        zipfile.extract(entry, "#{DB_PATH}/#{entry}")
      end
    end

    rescue
      nil
      # I'm going to ignore this and just overwrite the files.
  end
  
  def db_filepath(file)
    "#{DB_PATH}/"+input_file(file)
  end

  def format_db(input, output)
    logger.debug {"Running: formatdb -i #{input} -o T -n #{output}"}
    system "/usr/local/bin/formatdb -i #{input} -o T -n #{output}"
  end

  def fasta_files
    # Review the contents of the directory, listing number of .fasta files that were found
    @fasta_filenames ||= Dir["#{DB_PATH}/*.fasta"]
  end
  
end