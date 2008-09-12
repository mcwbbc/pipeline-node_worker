  INSTANCES_ARRAY = [ ['Small', 'm1.small'],
                      ['Medium', 'c1.medium'],
                      ['XX-Large', 'c1.xlarge']
                    ]

  INSTANCES_HASH = INSTANCES_ARRAY.inject({}) do |result, element|
    result[element.last] = element.first
    result
  end

  SEARCHER_ARRAY = [ ['OMSSA','omssa'],
                     ['Tandem','tandem']
                   ]

  SEARCHER_HASH = SEARCHER_ARRAY.inject({}) do |result, element|
     result[element.last] = element.first
     result
   end

  DEBUG = false

  PIPELINE = '/pipeline'

  PIPELINE_TMP = "/pipeline/tmp-#{$$}"
  UNPACK_DIR = "#{PIPELINE_TMP}/unpack"
  PACK_DIR = "#{PIPELINE_TMP}/pack"
  TANDEM_PATH = "/pipeline/bin/tandem"
  OMSSA_PATH = "/pipeline/bin/omssa"
  DB_PATH = "/pipeline/dbs"

  DB_BUCKET = 'pipeline-databases'
  PARAMETER_FILENAME = "parameters.conf"

  LAUNCH = 'LAUNCH'
  START = 'START'
  FINISH = 'FINISH'
  CREATED = 'CREATED'
  UNPACK = 'UNPACK'
  PROCESS = 'PROCESS'
  JOBUNPACKING = "JOBUNPACKING"
  JOBUNPACKED = "JOBUNPACKED"
  PACK = "PACK"
  DOWNLOAD = "DOWNLOAD"
  FINISHED = "FINISHED"
  NEWJOB = "NEWJOB"

  HOUR = 3600
  FIFTYFIVE = 3300
  SEARCHERS = ['omssa', 'tandem']
