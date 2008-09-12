class Aws

  include Utilities

  def initialize # this will take a hash, and create instance variables and getters/setters for each hash key
    begin
      # Create SQS object using my AWS access info (set in environment variables)
      @sqs = RightAws::SqsGen2.new(AWS_ACCESS, AWS_SECRET)
      # Create S3Interface object to allow us to upload and download stuff from our S3 buckets
      @s3i = RightAws::S3Interface.new(AWS_ACCESS, AWS_SECRET)
      # Create EC2 object
      @ec2 = RightAws::Ec2.new(AWS_ACCESS, AWS_SECRET)
      # create the bucket, just to make sure it exists
      create_bucket
    rescue RightAws::AwsError => e
      logger.error {"AWS: #{e}"}
      exit(1)
    end
  end

  def put_object(object_name, object_data, headers={})
    s3i.put(BUCKET_NAME, object_name, object_data, headers)
  end

  def get_object(object_name)
    s3i.get(BUCKET_NAME, object_name)
  end

  def delete_folder(folder_name)
    s3i.delete_folder(BUCKET_NAME, folder_name)
  end

  def delete_object(name)
    s3i.delete_folder(BUCKET_NAME, name)
  end

  def send_node_message(message)
    node_queue.send_message(message)
  end

  def send_head_message(message)
    head_queue.send_message(message)
  end

  def send_created_chunk_message(message)
    created_chunk_queue.send_message(message)
  end

  def send_finished_message(message)
    finished_queue.send_message(message)
  end

  def create_bucket
    # create the storage bucket
    @bucket ||= s3i.create_bucket(BUCKET_NAME)
  end

  def node_queue
    @node_queue ||= sqs.queue(NODE_QUEUE_NAME, true)
  end

  def head_queue
    @head_queue ||= sqs.queue(HEAD_QUEUE_NAME, true)
  end

  def created_chunk_queue
    @created_chunk_queue ||= sqs.queue(CREATED_CHUNK_QUEUE_NAME, true)
  end

  def finished_queue
    @finished_queue ||= sqs.queue(FINISHED_QUEUE_NAME, true)
  end

  def ec2
    @ec2 ||= RightAws::Ec2.new(AWS_ACCESS, AWS_SECRET)
  end

  def sqs
    @sqs ||= RightAws::SqsGen2.new(AWS_ACCESS, AWS_SECRET)
  end  

  def s3i
    @s3i ||= RightAws::S3Interface.new(AWS_ACCESS, AWS_SECRET)
  end
  
end