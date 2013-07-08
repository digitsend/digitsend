module DigitSend
  class Repository
    class <<self
      def upload(repo_name, path, filename, data = nil)
        begin
          uuid = Client.upload_s3_file(filename, data)
        rescue Errno::ECONNREFUSED
          return create_version_with_content(repo_name, path, filename, data)
        end

        create_version_with_s3_file(repo_name, path, uuid)
      end

      private

        def create_version_with_s3_file(repo_name, path, uuid)
          Client.call '/files/versions',
            repo_name: repo_name,
            path: path,
            repo_file_version: {
              s3_file_uuid: uuid
            }
        end

        def create_version_with_content(repo_name, path, filename, data)
          Client.call '/files/versions',
            repo_name: repo_name,
            path: path,
            direct_upload: {
              filename: filename,
              data: Client.stream_for_data(filename, data).read
            }
        end
    end
  end
end
