# Based on http://geoff.evason.name/2008/10/27/simple-currency-conversion-rate-api-consumption-for-ruby-rails/
require "cgi"
require "uri"
require "net/https"
require "rexml/document"

module XavierMedia
  @cache = nil
  @cache_time = nil
  
  def self.exchange_rate(target, relative_to)
    if @cache && @cache_time && Time.now-@cache_time < 60*60*6 # 6 hours 
      xml = @cache
    else
      url = URI.parse("http://api.finance.xaviermedia.com/api/latest.xml")
      resp = Net::HTTP.get(url)
      xml  = REXML::Document.new(resp)
      @cache = xml
      @cache_time = Time.now
    end

    source_rate = nil
    target_rate = nil
    xml.elements.each("//exchange_rates/fx") do |el|
      if el.elements[1].text == target
        target_rate = el.elements[2].text.to_f
      end
      if el.elements[1].text == relative_to
        source_rate = el.elements[2].text.to_f
      end
    end

    if !source_rate || !target_rate
      raise Exception.new("Couldn't find conversion between #{to} and #{from}")
    end
    
    return source_rate / target_rate
  end
end