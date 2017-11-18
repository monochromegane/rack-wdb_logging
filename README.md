# Rack::WdbLogging

Rack::WdbLogging collects all activities on rack middleware.

このリポジトリは技術評論社刊「WEB+DB PRESS Vol.102」の連載「実践！ 先進的インフラ運用」第4回「サービス改善につながるログ活用基盤の構築」のRackミドルウェアに関する参考実装です。

This is a reference implementation of Rack middleware introduced in "WEB+DB PRESS Vol. 102" series "Advanced infrastructure operation" 4th.

http://gihyo.jp/magazine/wdpress/archive/2017/vol102

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rack-wdb_logging'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-wdb_logging

## Usage

First, setup td-agent in your server.

```
# Input
<source>
  @type forward
</source>

# Output
<match wdb_development.**>
  @type tdlog
  apikey YOUR_API_KEY
  auto_create_table
  buffer_type file
  buffer_path /var/log/td-agent/buffer/td
  use_ssl true
</match>
```

Then, prepare a configuration file the following:

`config/initializers/rack-wdb_logging.rb`

```rb
Rails.application.config.app_middleware.insert_after ActionDispatch::Callbacks, Rack::WdbLogging do |config|
  config.db_name       = 'wdb'
  config.environment   = Rails.env
  config.fluent_host   = '127.0.0.1'
  config.enable_fluent = true # or Rails.env.production?
end
```

Then, access your Rails application.


If you need application layer information, you can call `set_activity` in your controller.

```rb
set_activity(:account_id, current_user.id)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rack-wdb_logging. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

