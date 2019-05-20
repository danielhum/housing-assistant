class HousesController < ApplicationController

  SCRAPERAPI_API_KEY = ENV['SCRAPERAPI_API_KEY']
  def index
    _retrieve_houses if params[:refresh]&.to_i == 1
    @houses = House.all
  end

  private

  def _retrieve_houses
    street = '145 Lorong 2 Toa Payoh'
    source_host = 'https://www.propertyguru.com.sg'
    source_url = "#{source_host}/property-for-sale?freetext=#{street}&market=residential"
    source_url = URI.encode source_url
    response_body = Rails.cache.fetch([:_retrieve_houses, Time.now.to_i % 900]) do
      response = HTTParty.get('https://api.scraperapi.com', query: {
        key: SCRAPERAPI_API_KEY, url: source_url })
      response.body
    end
    doc = Nokogiri::HTML(response_body)
    links = doc.css '.listing-card a.nav-link'
    links.each do |link|
      attrs = link.attributes
      title = attrs['title']&.to_s

      uri = URI(source_host + attrs['href']&.to_s.sub(/#.*/,''))
      uri.query = nil # remove params to aid in unique check
      url = uri.to_s
      next if title.blank? || url.blank?

      House.where(street: title, url: url).first_or_create!
    end
  end
end
