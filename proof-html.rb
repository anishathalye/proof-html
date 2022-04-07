require 'html-proofer'
require 'json'
require 'uri'

CHROME_FROZEN_UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.0.0 Safari/537.36"

def get_bool(name, fallback)
  s = ENV["INPUT_#{name}"]
  return fallback if s.nil? or s == ''
  case s
  when /^t/i # matches "t", "true", "True"
    true
  when /^y/i # matches "y", "yes", "Yes"
    true
  when "1"
    true
  else
    false
  end
end

def get_int(name, fallback)
  s = ENV["INPUT_#{name}"]
  return fallback if s.nil? or s == ''
  s.to_i
end

def get_str(name)
  s = ENV["INPUT_#{name}"]
  s.nil? ? "" : s
end

url_ignore_re = get_str("URL_IGNORE_RE").split("\n").map { |s| Regexp.new s }
url_ignore = get_str("URL_IGNORE").split("\n").concat url_ignore_re
tokens_str = get_str("TOKENS")
tokens = JSON.parse (tokens_str == "" ? "{}" : tokens_str)
internal_domains = get_str("INTERNAL_DOMAINS").split("\n")

options = {
  :cache => { :timeframe => "1d" },
  :check_external_hash => get_bool("CHECK_EXTERNAL_HASH", true),
  :check_html => get_bool("CHECK_HTML", true),
  :check_img_http => get_bool("CHECK_IMG_HTTP", true),
  :check_opengraph => get_bool("CHECK_OPENGRAPH", true),
  :check_favicon => get_bool("CHECK_FAVICON", true),
  :empty_alt_ignore => get_bool("EMPTY_ALT_IGNORE", false),
  :enforce_https => get_bool("ENFORCE_HTTPS", true),
  :external_only => get_bool("EXTERNAL_ONLY", false),
  :hydra => {
    :max_concurrency => get_int("MAX_CONCURRENCY", 50),
  },
  :internal_domains => internal_domains,
  :typhoeus => {
    :connecttimeout => get_int("CONNECT_TIMEOUT", 30),
    :followlocation => true,
    :headers => {
      "User-Agent" => CHROME_FROZEN_UA,
    },
    :timeout => get_int("TIMEOUT", 120),
  },
  :url_ignore => url_ignore,
}

begin
  proofer = HTMLProofer.check_directory(get_str("DIRECTORY"), options)
  proofer.before_request do |request|
    uri = URI.parse request.url
    base = "#{uri.scheme}://#{uri.host}"
    token = tokens[base]
    request.options[:headers]['Authorization'] = "Bearer #{token}" unless token.nil?
  end
  proofer.run
rescue => msg
  puts "#{msg}"
end
