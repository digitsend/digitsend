module DigitSend
  class Repository
    class <<self
      def self.upload(repo_name, path, filename, data = nil)
        begin
          uuid = Client.upload_s3_file(filename, data)
        rescue
          return create_version_with_s3_file(filename, data)
        end

        create_version_with_s3_file(uuid)
      end

      private

        def create_version_with_s3_file(uuid)
          Client.call '/files/versions',
            repo_name: repo_name,
            path: path,
            repo_file_version: {
              s3_file_uuid: uuid
            }
        end

        def create_version_with_content(filename, data)
          Client.call '/files/versions',
            repo_name: repo_name,
            path: path,
            repo_file_version: {
              data: stream_for_data(filename, data).read
            }
        end
    end
  end
end
