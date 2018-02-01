# frozen_string_literal: false

require 'active_support'
require 'active_support/core_ext'
require 'icobench/version'
require 'http'
require 'nokogiri'

module IcoBench
  BASE_URL = 'https://icobench.com'.freeze

  # @param bonus [Boolean] Bonus available
  # @param bounty [Boolean] Bounty available
  # @param public_team [Boolean] Public team
  # @param expert_ratings [Boolean] Expert ratings
  # @return [Array<Hash>]
  # @see https://icobench.com/icos

  https://icobench.com/icos?filterBonus=on&filterBounty=on&filterTeam=on&filterExpert=on&filterSort=&filterCategory=all&filterRating=any&filterStatus=any&filterCountry=Afghanistan&filterRegistration=0&filterExcludeArea=Benin&filterPlatform=CryptoNote&filterCurrency=DASH&s=&filterStartAfter=2018-01-02&filterEndBefore=2018-01-01
  def self.icos(bonus: nil, bounty: nil, public_team: nil, expert_ratings: nil)
    params = {
      bonus: bonus.eql?(true) ? 'on' : nil,
      bounty: bounty.eql?(true) ? 'on' : nil,
      public_team: public_team.eql?(true) ? 'on' : nil,
      expert_ratings: expert_ratings.eql?(true) ? 'on' : nil
    }.compact.to_param

    url = "#{BASE_URL}/icos"
    url << "?#{params}" if params.present?

    response = HTTP.get(url)
    JSON.parse(response.body.to_s, symbolize_names: true)
  end

  # @param id [Integer] Coinmarketcap coin id
  # @param currency [String] Country currency code to convert price
  # @return [Hash]
  def self.coin(id, currency: nil)
    params = {
      convert: currency
    }.compact.to_param

    url = "#{API_URL}/ticker/#{id}/"
    url << "?#{params}" if params.present?

    response = HTTP.get(url)
    json = JSON.parse(response.body.to_s, symbolize_names: true)
    json.is_a?(Array) ? json.first : json
  end

  # @param symbol [String] Coin symbol
  # @return [Hash]
  def self.coin_by_symbol(symbol)
    response = HTTP.get("#{API_URL}/ticker/?limit=0")
    json = JSON.parse(response.body.to_s, symbolize_names: true)
    json.find { |x| x[:symbol].strip.casecmp(symbol.strip.upcase).zero? }
  end

  # @param id [String] Coin market cap id
  # @param symbol [String] Coin symbol
  # @return [Array<Hash>]
  def self.coin_markets(id: nil, symbol: nil)
    raise ArgumentError.new('id or symbol is required') if id.blank? && symbol.blank?

    coin_id = symbol.present? ? coin_by_symbol(symbol)[:id] : id
    response = HTTP.get("#{BASE_URL}/currencies/#{coin_id}/\#markets")
    html = Nokogiri::HTML(response.body.to_s)
    rows = html.css('table#markets-table tbody tr')

    markets = rows.each_with_object([]) do |row, arr|
      td = row.css('td')
      arr << {
        source: td[1].text.strip,
        pair: td[2].text.strip,
        volume_usd: td[3].text.strip[/\$(.+)/, 1].delete(',').to_f,
        price_usd: td[4].text.strip[/\$(.+)/, 1].delete(',').to_f,
        volume_percentage: td[5].text.to_f,
        last_updated: td[6].text.strip
      }
    end

    markets
  end

  # @param currency [String] Country currency code to convert price
  # @return [Hash]
  def self.global(currency: nil)
    params = {
      convert: currency
    }.compact.to_param

    url = "#{API_URL}/global/"
    url << "?#{params}" if params.present?

    response = HTTP.get(url)
    JSON.parse(response.body.to_s, symbolize_names: true)
  end

  # @param id [String] Coinmarketcap coin id
  # @param start_date [String] Start date (YYYY-MM-DD)
  # @param end_date [String] End date (YYYY-MM-DD)
  # @return [Array<Hash>]
  def self.historical_price(id, start_date, end_date)
    sd = start_date.to_date.to_s.delete('-')
    ed = end_date.to_date.to_s.delete('-')

    url = "#{BASE_URL}/currencies/#{id}/historical-data/?start=#{sd}&end=#{ed}"
    response = HTTP.get(url)
    html = Nokogiri::HTML(response.body.to_s)
    rows = html.css('#historical-data table tbody tr')

    prices = rows.each_with_object([]) do |row, arr|
      td = row.css('td')
      daily = {
        date: Date.parse(td[0].text).to_s,
        open: td[1].text.to_f,
        high: td[2].text.to_f,
        low: td[3].text.to_f,
        close: td[4].text.to_f
      }

      daily[:average] = ((daily[:high] + daily[:low]).to_d / 2).to_f
      arr << daily
    end

    prices
  end
end
