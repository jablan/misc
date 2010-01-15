# :#include: ../rdoc/emailoutputter
require 'log4r'
require 'log4r/outputter/outputter'
require 'log4r/staticlogger'
require 'xmpp4r/client'

module Log4r

  class XMPPOutputter < Outputter
    attr_reader :jid, :pwd, :subject, :recipient

    def initialize(_name, hash={})
      super(_name, hash)
      validate_xmpp_params(hash)
      begin
        init_xmpp_connection
      rescue Exception => e
        Logger.log_internal(-2) {
          "Error connecting with XMPP client: #{e}"
        }
        raise e
        self.level = OFF
      end
    end

    # send out an email with the current buffer
#    def flush
#      synch { send_mail }
#      Logger.log_internal {"Flushed EmailOutputter '#{@name}'"}
#    end

    private

    def validate_xmpp_params(hash)
      @jid = hash[:jid] || hash['jid']
      raise ArgumentError, 'Must specify Jabber ID' if @jid.nil?
      @pwd = hash[:pwd] || hash['pwd']
      @subject = hash[:subject] || hash['subject']
      @recipient = hash[:recipient] || hash['recipient']
      raise ArgumentError, 'Must specify message recipient' if @recipient.nil?
    end

    def init_xmpp_connection
      jid = Jabber::JID.new(@jid)
      @cl = Jabber::Client.new(jid)
      @cl.connect
      @cl.auth(@pwd)
    end

    def canonical_log(event)
      synch {
        m = Jabber::Message::new(@recipient, @formatter.format(event).chomp)
        @cl.send m
#@cl.close
      }
    end

  end
end

if $0 == __FILE__
#  Jabber::debug = true
  logger = Log4r::Logger.new 'test'
  o = Log4r::XMPPOutputter.new 'to', :jid => 'jabber.outputter@gmail.com/Testing', :pwd => 'j123123', :recipient => 'j123123@gmail.com'
#  mylog = Logger.new 'mylog'
#  mylog.outputters = Outputter.stdout
#
  logger.outputters = o
  sleep(5)
  logger.info "hello test log!"
  sleep(5)
end 
