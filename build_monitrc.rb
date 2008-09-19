#!/usr/bin/env ruby

# this script launches a watcher with listens to the node queue to process messages
# we launch it with an id, so we can run more than one per server

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


config = {}
LOGGER = Logger.new("/pipeline/pipeline.log")
aws = AwsParameters.new
config = aws.run

workers = config['workers'].blank? ? 1 : config['workers'].to_i

LOGGER.debug { "Creating monitrc files for #{workers} workers" }

template = File.read('config/node.monitrc.template')
text = ""
(1..workers).each do |worker|
  text << template.gsub(/ID/, worker.to_s)
end
text << "\n"
File.open('config/node.monitrc', 'w') { |file| file.puts text}
