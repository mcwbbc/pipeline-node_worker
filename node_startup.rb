#!/usr/bin/env ruby

# this script will run a loader
# which will load a number of watcher instances, which in turn will launch workers
# to process the messages off the queue.
# this will allow multiple watchers to be launched per machine, instead of a single

require 'rubygems'
require 'net/http'
require 'uri'
require 'yaml'
require 'right_aws'
require 'right_http_connection'
require 'zip/zip'
require 'zip/zipfilesystem'
require 'fileutils'
require 'logger'

# load order is important
require 'lib/constants'
require 'lib/utilities'

require 'lib/aws'
require 'lib/aws_parameters'

require 'lib/searcher'
require 'lib/omssa'
require 'lib/tandem'

require 'lib/unpacker'
require 'lib/packer'
require 'lib/watcher'
require 'lib/worker'

  LOGGER = Logger.new("/pipeline/pipeline.log")
  aws = AwsParameters.new
  config = aws.run

  # Abort if AWS access key id or secret access key were not provided
  if !config.has_key?('aws_access') || !config.has_key?('aws_secret') || !config.has_key?('instance-id') then
    LOGGER.debug { "Instance must be launched with aws_access, aws_secret and instance_id parameters, but got: \"#{config_str}\"" }
    exit
  end

  AWS_ACCESS = config['aws_access']
  AWS_SECRET = config['aws_secret']
  INSTANCE_ID = config['instance-id']
  INSTANCE_TYPE = config['instance-type']
  AMI_ID = config['ami-id']
  HOSTNAME = config['public-hostname']

  BUCKET_NAME = "#{AWS_ACCESS}-pipeline"
  NODE_QUEUE_NAME = "#{AWS_ACCESS}-node"
  HEAD_QUEUE_NAME = "#{AWS_ACCESS}-head"
  FINISHED_QUEUE_NAME = "#{AWS_ACCESS}-finished"
  CREATED_CHUNK_QUEUE_NAME = "#{AWS_ACCESS}-created-chunk"

  AWS = Aws.new

  @watcher = Watcher.new
  @watcher.run

exit(1)
