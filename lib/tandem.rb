class Tandem < Searcher

INPUT_XML = "#{PIPELINE_TMP}/input.xml"

INPUT = <<XML
<?xml version="1.0"?>
<bioml>
	<note type="input" label="list path, default parameters">/pipeline/bin/tandem/default_input.xml</note>
	<note type="input" label="list path, taxonomy information">/pipeline/bin/tandem/taxonomy.xml</note>
	<note type="input" label="output, path hashing">no</note>
	<note type="input" label="spectrum, path">DATA_SOURCE</note>
	<note type="input" label="output, path">OUTPUT</note>
PARAMETERS
</bioml>
XML

  def build_xml
    xml = INPUT.gsub(/PARAMETERS/, parameters).gsub(/DATA_SOURCE/, input_file).gsub(/OUTPUT/, "#{output_file}")
    File.open(INPUT_XML, File::RDWR|File::CREAT) do |f|
      f << xml
    end
  end

  # simple function to run omssa from the command line with a few basic parameters
  def run
    build_xml
    logger.debug {"Running: #{TANDEM_PATH}/tandem.exe #{PIPELINE_TMP}"}
    system "#{TANDEM_PATH}/tandem.exe #{PIPELINE_TMP}"
  end

end