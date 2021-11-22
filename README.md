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
  searchable do |o|
    o.relation :variations, :title, :stock_status

    # Attributes can be used for both keyed and unkeyed searching by default, but you can pass either `keyed: false` or
    # `unkeyed: false` to restrict when the attribute is searched.
    o.attribute :title
    o.attribute :rating, unkeyed: false

    # You can shorten the search keyword by passing the desired search term first, and then the real attribute name
    # as the second argument.
    #  => "desc*=foo"
    o.attribute :desc, :description

    # It's also possible to query entirely custom Arel nodes by passing a block which returns the Arel node to query.
    # You could use this to query a person's full name by concatenating their first and last name columns, for example.
    o.attribute :title_length, unkeyed: false do
      Arel::Nodes::NamedFunction.new('LENGTH', [
        arel_table[:title]
      ])
    end
  end
end
```

This creates a ```.search``` method on your record class which accepts a single query argument:

```ruby
Product.search('plain shirt rating>=3')
```

## Development

After checking out the repo, run `bundle exec rake spec` to run the tests.

To install this gem onto your machine, run `bundle exec rake install`.
