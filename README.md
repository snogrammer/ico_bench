[![Gem Version](https://badge.fury.io/rb/ico_bench.svg)](https://badge.fury.io/rb/ico_bench)

# IcoBench
## WIP
Ruby Gem that parses ICO token information, ratings, and expert information from IcoBench.com.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ico_bench', '~> 0.1.0'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install icobench

## Usage

### ICO List

```ruby
# @param params [Hash] Query params. See #filters
# @return [Hash]
IcoBench.icos

=> {:current_page=>1,
 :total_pages=>146,
 :response_time=>0.2552617e1,
 :icos=>
  [{:name=>"Acorn Collective",
    :url=>"https://icobench.com/ico/acorn-collective",
    :premium=>true,
    :tag=>
     "Acorn is building a blockchain based crowdfunding platform that's the first to be free and open to any legal project in any country.KYC: Yes | Whitelist: Yes | Restrictions: USA, China",
    :start_date=>Mon, 29 Jan 2018,
    :end_date=>Mon, 19 Feb 2018,
    :rating=>4.1},
   {:name=>"Gilgamesh Platform",
    :url=>"https://icobench.com/ico/gilgamesh-platform",
    :premium=>true,
    :tag=>"Knowledge-sharing social network platform based on Ethereum Blockchain.KYC: Yes | Whitelist: No",
    :start_date=>Mon, 15 Jan 2018,
    :end_date=>Mon, 26 Mar 2018,
    :rating=>4.1}]
  }
```

#### Filters

```ruby
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
```

### ICO People/Person information

```ruby
# @param type [String] Valid values: all, registered, experts
# @param page [Integer]
# @param search [String] Name search
# @return [Hash]
IcoBench.people(type: nil, page: nil, search: nil)

=> {:current_page=>1,
 :total_pages=>1346,
 :response_time=>0.2409899e1,
 :people=>
  [{:name=>"Simon Cocking",
    :url=>"https://icobench.com/u/simon-cocking",
    :tag=>"Editor in Chief, Cryptocoin.News",
    :icos=>"Experty, Bitindia, ClearPoll, Jincor, and 20 more",
    :ico_success_score=>82.182},
   {:name=>"David Drake",
    :url=>"https://icobench.com/u/david-drake",
    :tag=>"Managing Partner",
    :icos=>"Ambrosus, Swarm Fund, Setcoin, 1World, and 18 more",
    :ico_success_score=>77.177}]
  }
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/kurt-smith/ico_bench. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the IcoBench project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/kurt-smith/ico_bench/blob/master/CODE_OF_CONDUCT.md).
