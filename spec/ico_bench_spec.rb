# frozen_string_literal: true

require 'spec_helper'

describe IcoBench do
  it { expect(IcoBench::VERSION).to eq('0.1.0') }

  describe '#icos' do
    it 'returns hash' do
      stub_request(:get, /icos/).and_return(body: fixture('icos.html'))
      response = described_class.icos
      expect(a_request(:get, /icos/)).to have_been_made.once
      expect(response).to be_a(Hash)
      expect(response.keys).to include(:current_page, :total_pages, :response_time, :icos)

      expect(response[:icos]).to be_a(Array)
      ico = response[:icos].first
      expect(ico.keys).to include(:name, :url, :premium, :tag, :start_date, :end_date, :rating)
      expect(ico).to eq(
        name: 'Acorn Collective',
        url: 'https://icobench.com/ico/acorn-collective',
        premium: true,
        tag: "Acorn is building a blockchain based crowdfunding platform that's the first to be free and open to any legal project in any country.KYC: Yes | Whitelist: Yes | Restrictions: USA, China",
        start_date: Date.parse('29 Jan 2018'),
        end_date: Date.parse('19 Feb 2018'),
        rating: 4.1
      )
    end
  end

  describe '#people' do
    it 'returns hash' do
      stub_request(:get, /people/).and_return(body: fixture('people.html'))
      response = described_class.people
      expect(a_request(:get, /people/)).to have_been_made.once
      expect(response).to be_a(Hash)
      expect(response.keys).to include(:current_page, :total_pages, :response_time, :people)

      expect(response[:people]).to be_a(Array)
      person = response[:people].first
      expect(person.keys).to include(:name, :url, :tag, :icos, :ico_success_score)
      expect(person).to eq(
        name: 'Jason Hung',
        url: 'https://icobench.com/u/jason-hung',
        tag: 'TimeBox co-founder |  ICO advisor | TokenSky advisor |Inventor | Serial Entrepreneur',
        icos: 'Water to the World, BeeSocials, EZPOS, Giza Device, and 5 more',
        ico_success_score: 32.432
      )
    end
  end
end
