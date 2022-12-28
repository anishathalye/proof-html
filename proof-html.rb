require "html-proofer"
require "json"
require "uri"

CHROME_FROZEN_UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/87.0.0.0 Safari/537.36"

def get_bool(name, fallback)
  s = ENV["INPUT_#{name}"]
  return fallback if s.nil? or s == ""
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
  return fallback if s.nil? or s == ""
  s.to_i
end

def get_str(name)
  s = ENV["INPUT_#{name}"]
  s.nil? ? "" : s
end

ignore_url_re = get_str("IGNORE_URL_RE").split("\n").map { |s| Regexp.new s }
ignore_url = get_str("IGNORE_URL").split("\n").concat ignore_url_re
tokens_str = get_str("TOKENS")
tokens = JSON.parse (tokens_str == "" ? "{}" : tokens_str)

swap_urls_str = get_str("SWAP_URLS")
swap_urls = JSON.parse (swap_urls_str == "" ? "{}" : swap_urls_str)
swap_urls.transform_keys! { |k| Regexp.new k }

checks = ["Links", "Scripts", "Images"]
if get_bool("CHECK_FAVICON", true)
  checks.push("Favicon")
end
if get_bool("CHECK_OPENGRAPH", true)
  checks.push("OpenGraph")
end

options = {
  :checks => checks,
  :cache => { :timeframe => {
    :internal => "1d",
    :external => "1d",
  } },
  :check_external_hash => get_bool("CHECK_EXTERNAL_HASH", true),
  :ignore_empty_alt => get_bool("IGNORE_EMPTY_ALT", false),
  :allow_missing_href => get_bool("ALLOW_MISSING_HREF", false),
  :enforce_https => get_bool("ENFORCE_HTTPS", true),
  :hydra => {
    :max_concurrency => get_int("MAX_CONCURRENCY", 50),
  },
  :typhoeus => {
    :connecttimeout => get_int("CONNECT_TIMEOUT", 30),
    :followlocation => true,
    :headers => {
      "User-Agent" => CHROME_FROZEN_UA,
    },
    :timeout => get_int("TIMEOUT", 120),
  },
  :ignore_urls => ignore_url,
  :swap_urls => swap_urls,
}

begin
  proofer = HTMLProofer.check_directory(get_str("DIRECTORY"), options)
  proofer.before_request do |request|
    uri = URI.parse request.url
    base = "#{uri.scheme}://#{uri.host}"
    token = tokens[base]
    request.options[:headers]["Authorization"] = "Bearer #{token}" unless token.nil?
  end
  proofer.run
rescue => msg
  puts "#{msg}"
  exit 1
end
