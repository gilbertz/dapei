# encoding: utf-8

namespace :notification do
  task :push => :environment do
    cert_path=Rails.root+ "public/uploads/shangjieba_certificate.pem"
    print cert_path
    pusher = Grocer.pusher(
      certificate: cert_path,      # required
      passphrase:  "",                       # optional
      gateway:     "gateway.sandbox.push.apple.com", # optional; See note below.
      port:        2195,                     # optional
      retries:     3                         # optional
    )

    @message="a test from shangjieb"
    @devices=Device.all
    @devices.each do |dev|
      print "device a"
      print dev.token
      #Resque.enqueue(Jobs::PushNotification, @message, dev, pusher)
        note = Grocer::Notification.new(
        device_token: dev.token,
        alert: @message,
        sound: 'default',
        badge: 0
        )
        print "we are here"
        pusher.push(note)
        print "after pushing"
      #end

    end

   
    #feedback = Grocer.feedback(
    #certificate: cert_path,
    #passphrase:  "",                        # optional
    #gateway:     "feedback.push.apple.com", # optional; See note below.
    #port:        2196,                      # optional
    #retries:     3                          # optional
    #)

    #feedback.each do |attempt|
      #print "Device #{attempt.device_token} failed at #{attempt.timestamp}"
    #end
    
  end

end
