require 'http_logger'
require 'logger'

module Gliffy
  class CLI::Task
    def initialize(options)
      if options["log-http"]
        enable_http_logging
      end

      @options = options
    end

    def enable_http_logging
      HttpLogger.logger = Logger.new(STDERR)
      HttpLogger.colorize = true
    end

    def stdout
      STDOUT
    end

    def account
      @account ||= load_account(@options)
    end

    def load_account(options)
      account_id, consumer_key, consumer_secret = load_credentials(options)
      api = Gliffy::API.new(account_id,
                            consumer_key,
                            consumer_secret)

      api.impersonate(options["user"])
      api.account
    end

    def load_credentials(options)
      if has_custom_credentials? options
        account_id = options["account-id"]
        consumer_key = options["consumer-key"]
        consumer_secret = options["consumer-secret"]
      else
        credentials = YAML.load_file(options["credentials"])

        account_id = credentials["gliffy"]["account"]
        consumer_key = credentials["gliffy"]["oauth"]["consumer_key"]
        consumer_secret = credentials["gliffy"]["oauth"]["consumer_secret"]
      end

      [account_id, consumer_key, consumer_secret]
    end

    def has_custom_credentials?(options)
      ["account-id",
       "consumer-key",
       "consumer-secret"].all? { |k| not options[k].nil? }
    end
  end
end
