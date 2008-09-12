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

  aws = AwsParameters.new
  config = aws.run

  AWS_ACCESS = config['aws_access']
  AWS_SECRET = config['aws_secret']

  BUCKET_NAME = "#{AWS_ACCESS}-pipeline"

  AWS = Aws.new

  @db = DatabaseInstaller.new
  @db.run

exit(1)
