# frozen_string_literal: true

require 'active_support'
require 'active_support/core_ext'
require 'ico_bench/version'
require 'http'
require 'nokogiri'

class IcoBench
  BASE_URL = 'https://icobench.com'

  class << self
    # @param params [Hash] Query params. See #filters
    # @return [Hash]
    # @see https://icobench.com/icos
    def icos(**params)
      url = "#{BASE_URL}/icos"
      query = filters(params)
      url << query if query.present?

      request_time = Time.now.to_f
      response = HTTP.get(url)
      html = Nokogiri::HTML(response.body.to_s)
      rows = html.css('div.ico_list table tr')
      return {} if rows.blank?

      icos = []

      rows.each_with_index do |row, index|
        next if index.zero? # table header row
        icos << parse_ico_row(row)
      end

      {
        current_page: params[:page] || 1,
        total_pages: html.css('div.pages a.num').last&.text&.to_i,
        response_time: (Time.now.to_f - request_time.to_d),
        icos: icos
      }
    end

    # @param type [String] Valid values: all, registered, experts
    # @param page [Integer]
    # @param search [String] Name search
    # @return [Hash]
    def people(type: nil, page: nil, search: nil)
      url = "#{BASE_URL}/people"
      params = {
        page: page,
        type: type,
        s: search.presence
      }.compact.to_param

      url << "?#{params}" if params.present?

      request_time = Time.now.to_f
      response = HTTP.get(url)
      html = Nokogiri::HTML(response.body.to_s)
      rows = html.css('div.ico_list table tr')
      return {} if rows.blank?

      people = []

      rows.each_with_index do |row, index|
        next if index.zero? # table header row
        people << parse_people_row(row)
      end

      {
        current_page: page.presence || 1,
        total_pages: html.css('div.pages a.num').last&.text&.to_i,
        response_time: (Time.now.to_f - request_time.to_d),
        people: people
      }
    end

    private

    # Optional query filters
    # @param order_desc [String] Valid values: rating, start, end, raised, name
    # @param order_asc [String] Valid values: rating, start, end, raised, name
    # @param page [Integer] Pagination
    # @param category [Integer] Category type via #filters response
    # @param platform [String] List the ICOs supported by a certain platform, e.g. "Ethereum"
    # @param accepting [String] List the ICOs those are accepting a certain currency, e.g. "BTC"
    # @param country [String] List the ICOs located in a certain country, e.g. "Australia" or "UK"
    # @param status [String] Valid values: active, ongoing, upcoming, ended
    # @param search [String] List the ICOs those have a certain string in the name, token name, tagline or short description, e.g. "VIB" or "gaming"
    # @param bonus [Boolean] List the ICOs that have a bonus
    # @param bounty [Boolean] List the ICOs that have a bounty
    # @param team [Boolean] List the ICOs that have a team
    # @param expert [Boolean] List the ICOs that have a expert
    # @param rating [Integer] List the ICOs that have rating 1-4+
    # @param start_after [String] List the ICOs starting from selected date (YYYY-MM-DD format)
    # @param before_after [String] List the ICOs ending before date (YYYY-MM-DD format)
    # @param registration [Integer] List the ICOs based on registration type and requirements - KYC / Whitelist.
    #    1 = With whitelist
    #    2 = Without whitelist
    #    3 = With KYC
    #    4 = Without KYC
    #    5 = With KYC and Whitelist
    #    6 = None
    # @param exclude_country [String] List the ICOs excluding all ICOs with restriction on that country
    # @return [String]
    def filters(**opts)
      filter = {
        orderDesc: opts[:order_desc],
        orderAsc: opts[:order_asc],
        page: opts[:page],
        category: opts[:category],
        platform: opts[:platform],
        accepting: opts[:accepting],
        country: opts[:country],
        status: opts[:status],
        s: opts[:search],
        bonus: opts[:bonus].present? ? 'on' : nil,
        bounty: opts[:bounty].present? ? 'on' : nil,
        team: opts[:team].present? ? 'on' : nil,
        expert: opts[:expert].present? ? 'on' : nil,
        rating: opts[:rating],
        startAfter: opts[:start_after],
        endBefore: opts[:end_before],
        registration: opts[:registration],
        excludeRestrictedCountry: opts[:exclude_country]
      }.compact.to_param

      "?#{filter}" if filter.present?
    end

    # @param row [Nokogiri<HTML>]
    # @return [Hash]
    def parse_ico_row(row)
      {
        name: row.css('td')[0].css('.content a.name').children.last.text,
        url: "#{BASE_URL}#{row.css('td')[0].css('.content a.name').attribute('href').text}",
        premium: row.css('td')[0].css('.content a.name a.premium').present?,
        tag: row.css('td')[0].css('.content p').text,
        start_date: parse_date(row.css('td')[1].text),
        end_date: parse_date(row.css('td')[2].text),
        rating: row.css('td')[3]&.text&.to_f
      }
    end

    # @param row [Nokogiri<HTML>]
    # @return [Hash]
    def parse_people_row(row)
      {
        name: row.css('td .people_content a').text,
        url: "#{BASE_URL}#{row.css('td .people_content a').attribute('href').text}",
        tag: row.css('td .people_content p').text,
        icos: row.css('td.rmv')[0]&.text,
        ico_success_score: row.css('td .iss_score').text.to_f
      }
    end

    def parse_date(date)
      Date.parse(date)
    rescue StandardError
      nil
    end
  end # self
end
