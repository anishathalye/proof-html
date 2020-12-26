require 'html-proofer'

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

def get_str(name, fallback="")
  s = ENV["INPUT_#{name}"]
  s.nil? ? fallback : s
end

url_ignore_re = get_str("URL_IGNORE_RE").split("\n").map { |s| Regexp.new s }
url_ignore = get_str("URL_IGNORE").split("\n").concat url_ignore_re

options = {
  :check_external_hash => get_bool("CHECK_EXTERNAL_HASH", true),
  :check_html => get_bool("CHECK_HTML", true),
  :check_img_http => get_bool("CHECK_IMG_HTTP", true),
  :check_opengraph => get_bool("CHECK_OPENGRAPH", true),
  :check_favicon => get_bool("CHECK_FAVICON", true),
  :empty_alt_ignore => get_bool("EMPTY_ALT_IGNORE", false),
  :enforce_https => get_bool("ENFORCE_HTTPS", true),
  :hydra => {
    :max_concurrency => get_int("MAX_CONCURRENCY", 10),
  },
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
  HTMLProofer.check_directory(get_str("DIRECTORY", "."), options).run
rescue => msg
  puts "#{msg}"
end
