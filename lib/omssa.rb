class Omssa < Searcher

  DATABASE = { "human" => "Uniprot_human_54_0",
               "rodent" => "Uniprot_rodent_54_0",
               "complete" => "Uniprot_complete_49_1",
               "mammals" => "Uniprot_all_mammals_49",
               "yeast" => "s_cerevisiae",
               "ecoli" => "ecoli_k12"
             }

  # simple function to run omssa from the command line with a few basic parameters
  def run
    logger.debug {"Running: #{OMSSA_PATH}/omssacl #{parameters} -fm #{input_file} -oc #{output_file} -ni"}
    system "#{OMSSA_PATH}/omssacl #{parameters} -fm #{input_file} -oc #{output_file} -ni"
  end

  def fasta_db
    db+".fasta"
  end

end