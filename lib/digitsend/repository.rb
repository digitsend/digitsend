module DigitSend
  class Repository
    def self.upload(repo_name, path, filename, data = nil)
      uuid = Client.upload_s3_file(filename, data)

      Client.call '/files/versions',
        repo_name: repo_name,
        path: path,
        repo_file_version: { s3_file_uuid: uuid }
    end
  end
end
