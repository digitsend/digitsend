# DigitSend

DigitSend is a secure email and file sharing service with a streamlined two-factor registration process.  This gem allows you to send email and upload files to share programmatically.

## Usage

### 1. API Key

You must set the API key before performing any operations.  API keys are granted on a per-user basis using the administration portal.  All operations are done on behalf of the user to which the API key belongs.

```ruby
DigitSend::Config.api_token = 'bdf6a88dcb7e3ff3df18afda99591360'
```
 
### 2. Sending Messages

The general approach:

```ruby
DigitSend::Message.send do |m|
  m.to "bob@example.com", "3125551234"
  m.to "tom@example.com", "7731112222"
  m.cc "fred@example.com"
  m.subject "Hello Bob, Tom, and Fred"
  m.body "Here's a message, hope you enjoy!"
  m.attach "report.xls"
  m.attach "notes.txt", "here's the contents of notes.txt"
end
```

A few things to note:

* Call to or cc multiple times to add multiple recipients.
* The second (optional) argument to the to and cc methods is that user's phone number.  The phone number is required if this is the first message being sent to the user.

### 3. DigitSend::MissingPhoneNumbers

This exception is thrown whenever an attempt is made to send a message to a new user without providing a phone number:

```ruby
begin
  DigitSend::Message.send do |m|
    m.to "bob@example.com"
    m.subject "Testing"
    m.body "Here's a test mesage"
  end
rescue DigitSend::MissingPhoneNumbers => ex
  puts "need phone numbers for: #{ex.email_addresses}"
end
```

### 4. Message File Attachments

The attach method can be called a number of ways:

```ruby
DigitSend::Message.send do |m|
  m.to "bob@example.com"
  m.subject "Here's some attachments"

  # Attach the report.xls file on disk.
  m.attach "/path/to/report.xls"

  # Attach a file with its contents specified as a string.
  m.attach "reports.txt", "contents of the file"

  # Attach a file with its contents specified as any object
  # that can be passed to UploadIO.new. 
  m.attach "picture.jpg", File.open("picture.jpg")
end
```

### 5. Uploading Files to Repositories

Repositories are referenced by name and must be created in using the admin portal.

```ruby
DigitSend::Repository.upload "Reports", "/Internal/#{Date.today}", "activity.csv"
```

* The first parameter is the name of the repository.
* The second parameter identifies the folder to which the file should belong.  Folders are created on the fly, mkdir_p style.
* The third parameter is the name of the file.
* The optional fourth parameter can be the string contents of the file or an object just like when attaching a file to a message.  (Above.)
