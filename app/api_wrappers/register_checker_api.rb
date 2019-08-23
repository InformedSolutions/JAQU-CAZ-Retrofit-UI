# frozen_string_literal: true

class RegisterCheckerApi < BaseApi
  base_uri ENV['RETROFIT_API_URL']

  class << self
    def register_job(file_name, correlation_id)
      params = {
        "filename": file_name,
        "s3Bucket": bucket_name
      }.to_json

      response = request(:post, "#{base_path}/jobs",
                         body: params, headers: custom_headers(correlation_id))
      response['jobName']
    end

    def job_status(job_uuid, correlation_id)
      response = request(:get, "#{base_path}/jobs/#{job_uuid}",
                         headers: custom_headers(correlation_id))
      response['status']
    end

    def job_errors(job_uuid, correlation_id)
      response = request(:get, "#{base_path}/jobs/#{job_uuid}",
                         headers: custom_headers(correlation_id))
      return nil unless response['status'] == 'FAILURE'

      response['errors']
    end

    private

    def bucket_name
      ENV['S3_AWS_BUCKET']
    end

    def custom_headers(correlation_id)
      {
        'Content-Type' => 'application/json',
        'X-Correlation-ID' => correlation_id
      }
    end

    def base_path
      '/v1/retrofit/register-csv-from-s3'
    end
  end
end
