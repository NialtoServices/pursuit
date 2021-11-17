# Pursuit

Advanced key-based searching for ActiveRecord objects.

## Installation

You can install **Pursuit** using the following command:

  $ gem install pursuit

Or, by adding the following to your `Gemfile`:

```ruby
gem 'pursuit'
```

### Usage

You can use the convenient DSL syntax to declare which attributes and relationships are searchable:

```ruby
class Product < ActiveRecord::Base
  has_search relationships: { variations: %i[title] },
             keyed_attributes: %i[title description rating],
             unkeyed_attributes: %i[title description]
end
```

This creates a ```.search``` method on your record class which accepts a single query argument:

```ruby
Product.search('plain shirt rating>=3')
```

## Development

After checking out the repo, run `bundle exec rake spec` to run the tests.

To install this gem onto your machine, run `bundle exec rake install`.
