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

  SEARCHERS = ['omssa', 'tandem']
