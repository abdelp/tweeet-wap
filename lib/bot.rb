require 'twitter'
require 'yaml'
require 'net/http'
require 'uri'
require_relative 'config'

class TwitterBot
    include Config
  
    def initialize(username)
      @client = Twitter::REST::Client.new do |config|
        config.consumer_key = CONSUMER_KEY
        config.consumer_secret = CONSUMER_SECRET
        config.access_token = ACCESS_TOKEN
        config.access_token_secret = ACCESS_TOKEN_SECRET
      end
      @username = username
      @tweets = []
    end
  
    private
  
    def get_tweet
      puts 'Retrieving tweets...'
      @tweets = @client.user_timeline(@username, count: 1)
    end
  
    def save_tweet
      File.write('tweets.yml', YAML.dump(@tweets[0].full_text))
    end

    def reset
      puts "\nProcess finished, it will restart in 6 hours."
      puts "\n\tPress CTRL + C to abort now."
      @tweets = []
    end
  
    def send_message
        message = @tweets[0].full_text
        begin
            uri = URI(WHATSAPP_URI)
          rescue URI::InvalidURIError
            uri = URI(URI.escape(WHATSAPP_URI))
          end
        
        req = Net::HTTP::Get.new(uri)
        res = Net::HTTP.get_response(uri)
        puts res.body
    end

    public
  
    def run
      loop do
        get_tweet
        @tweets.each { |tweet| puts tweet.full_text + "\n" }
        save_tweet
        send_message
        reset
        sleep 60
      end
    end
  end