# -*- encoding : utf-8 -*-
require 'net/smtp'
require 'tlsmail'
require 'yaml'
 
class SMTPGoogleMailer
  attr_accessor :smtp_info
 
  def send_plain_email from, to, subject, body
    mailtext = <<EOF
From: #{from}
To: #{to}
Subject: #{subject}
 
#{body}
EOF
    send_email from, to, mailtext
  end
 
  def send_attachment_email from, to, subject, body, attachment
# Read a file and encode it into base64 format
    begin
      filecontent = File.read(attachment)
      encodedcontent = [filecontent].pack("m")   # base64
    rescue
      raise "Could not read file #{attachment}"
    end
 
    marker = (0...50).map{ ('a'..'z').to_a[rand(26)] }.join
    part1 =<<EOF
From: #{from}
To: #{to}
Subject: #{subject}
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary=#{marker}
--#{marker}
EOF
 
# Define the message action
    part2 =<<EOF
Content-Type: text/plain
Content-Transfer-Encoding:8bit
 
#{body}
--#{marker}
EOF
 
# Define the attachment section
    part3 =<<EOF
Content-Type: multipart/mixed; name=\"#{File.basename(attachment)}\"
Content-Transfer-Encoding:base64
Content-Disposition: attachment; filename="#{File.basename(attachment)}"
 
#{encodedcontent}
--#{marker}--
EOF
 
    mailtext = part1 + part2 + part3
 
    send_email from, to, mailtext
  end
 
  private
 
  def send_email from, to, mailtext
    begin 
      Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE)
      Net::SMTP.start(@smtp_info[:smtp_server], @smtp_info[:port], @smtp_info[:helo], @smtp_info[:username], @smtp_info[:password], @smtp_info[:authentication]) do |smtp|
        smtp.send_message mailtext, from, to
      end
    rescue => e  
      raise "Exception occured: #{e} "
      exit -1
    end  
  end
end
 
if __FILE__ == $0
  from = ARGV[1]
  to = ARGV[2]
  subject = ARGV[3]
  body = ARGV[4]
  attachment = ARGV[5]
  smtp_info = 
    begin
      YAML.load_file(ARGV[0])
    rescue
      $stderr.puts "Could not find SMTP info"
      exit -1
    end

  print smtp_info 
  mailer = SMTPGoogleMailer.new
  mailer.smtp_info = smtp_info
 
  if ARGV[4]
    begin
      mailer.send_attachment_email from, to, subject, body, attachment
    rescue => e
      $stderr.puts "Something went wrong: #{e}"
      exit -1
    end
  else
    begin
      mailer.send_plain_email from, to, subject, body
    rescue => e
      $stderr.puts "Something went wrong: #{e}"
      exit -1
    end
  end
end
