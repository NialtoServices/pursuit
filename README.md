# Pursuit

Search your ActiveRecord objects with ease!

## Installation

You can install **Pursuit** using the following command:

  $ gem install pursuit

Or, by adding the following to your `Gemfile`:

```ruby
gem 'pursuit'
```

### Usage

Pursuit comes with three different strategies for interpreting queries:

- Simple
- Term
- Predicate

### Simple Search

Simple takes the entire query and generates a SQL `LIKE` (or `ILIKE` for *PostgreSQL*) statement for each attribute
added to the search instance. Here's an example of how you might use simple to search a hypothetical `Product` record:

```ruby
search = Pursuit::SimpleSearch.new(default_table: Product.arel_table)
search.search_attribute(:title)
search.search_attribute(:subtitle)
search.apply('Green Shirt', Product.all)
```

Which results in the following SQL query:

```sql
SELECT
  "products".*
FROM
  "products"
WHERE
  "products"."title" LIKE '%Green Shirt%'
  OR "products"."subtitle" LIKE '%Green Shirt%'
```

The initializer method also accepts a block, which is evaluated within the instance's context. This can make it cleaner
when declaring the searchable attributes:

```ruby
search = Pursuit::SimpleSearch.new(default_table: Product.arel_table) do
  search_attribute :title
  search_attribute :subtitle
end

search.apply('Green Shirt', Product.all)
```

You can also pass custom `Arel::Attribute::Attribute` objects, which are especially useful when using joins:

```ruby
search = Pursuit::SimpleSearch.new(default_table: Product.arel_table) do
  search_attribute :title
  search_attribute ProductVariation.arel_table[:title]
end

search.apply('Green Shirt', Product.left_outer_joins(:variations).group(:id))
```

Which results in the following SQL query:

```sql
SELECT
  "products".*
FROM
  "products"
  LEFT OUTER JOIN "product_variations" ON "product_variations"."product_id" = "products"."id"
WHERE
  "products"."title" LIKE '%Green Shirt%'
  OR "product_variations"."title" LIKE '%Green Shirt%'
GROUP BY
  "products"."id"
```

### Term Search

Term searches break a query into individual terms on spaces, while providing double and single quoted strings as a
means to include spaces. Here's an example of using term searches on the same `Product` record from earlier:

```ruby
search = Pursuit::TermSearch.new(default_table: Product.arel_table) do
  search_attribute :title
  search_attribute :subtitle
end

search.apply('Green "Luxury Shirt"', Product.all)
```

Which results in a SQL query similar to the following:

```sql
SELECT
  "products".*
FROM
  "products"
WHERE
  (
    "products"."title" LIKE '%Green%'
    OR "products"."subtitle" LIKE '%Green%'
  ) AND (
    "products"."title" LIKE '%Luxury Shirt%'
    OR "products"."subtitle" LIKE '%Luxury Shirt%'
  )
```

### Predicate Search

Predicate searches use a parser (implemented with the `parslet` gem) to provide a minimal query language.
This syntax is similar to the `WHERE` and `HAVING` clauses in SQL, but uses only symbols for operators and joins.

Attributes can only be used in predicate searches when they have been added to the list of permitted attributes.
You can also rename attributes, and add attributes for joined records.

Here's a more complex example of using predicate-based searches with joins on the `Product` record from earlier:

```ruby
search = Pursuit::PredicateSearch.new(default_table: Product.arel_table) do
  # Product Attributes
  permit_attribute :title

  # Product Category Attributes
  permit_attribute :category_name, ProductCategory.arel_table[:name]

  # Product Variation Attributes
  permit_attribute :variation_title, ProductVariation.arel_table[:title]
  permit_attribute :variation_currency, ProductVariation.arel_table[:currency]
  permit_attribute :variation_amount, ProductVariation.arel_table[:amount]
end

search.apply(
  'title = "Luxury Shirt" & (variation_amount = 0 | variation_amount > 1000)',
  Product.left_outer_join(:category, :variations).group(:id)
)
```

This translates to "a product whose title is 'Luxury Shirt' and has at least one variation with either an amount of 0,
or an amount greater than 1000", which could be expressed in SQL as:

```sql
SELECT
  "products".*
FROM
  "products"
  LEFT OUTER JOIN "product_categories" ON "product_categories"."id" = "products"."category_id"
  LEFT OUTER JOIN "product_variations" ON "product_variations"."product_id" = "products"."id"
WHERE
  "products"."title" = 'Luxury Shirt'
  AND (
    "product_variations"."amount" = 0
    OR "product_variations"."amount" > 1000
  )
GROUP BY
  "products"."id"
```

You can use any of the following operators in comparisons:

- `=` checks if the attribute is equal to the value.
- `!=` checks if the attributes is not equal to the value.
- `>` checks if the attribute is greater than the value.
- `<` checks if the attribute is less than the value.
- `>=` checks if the attribute is greater than or equal to the value.
- `<=` checks if the attribute is less than or equal to the value.
- `~` checks if the attribute matches the value (using `LIKE` or `ILIKE`).
- `!~` checks if the attribute does not match the value (using `LIKE` or `ILIKE`).

Predicate searches also support "aggregate modifiers" which enable the use of aggregate functions, however this feature
must be explicitly enabled and requires you to use a `GROUP BY` clause:

```ruby
search = Pursuit::PredicateSearch.new(default_table: Product.arel_table, permit_aggregate_modifiers: true) do
  # Product Attributes
  permit_attribute :title

  # Product Category Attributes
  permit_attribute :category, ProductCategory.arel_table[:id]
  permit_attribute :category_name, ProductCategory.arel_table[:name]

  # Product Variation Attributes
  permit_attribute :variation, ProductVariation.arel_table[:id]
  permit_attribute :variation_title, ProductVariation.arel_table[:title]
  permit_attribute :variation_currency, ProductVariation.arel_table[:currency]
  permit_attribute :variation_amount, ProductVariation.arel_table[:amount]
end

search.apply(
  'title = "Luxury Shirt" & #variation > 5',
  Product.left_outer_join(:category, :variations).group(:id)
)
```

And the resulting SQL from this query:

```sql
SELECT
  "products".*
FROM
  "products"
  LEFT OUTER JOIN "product_categories" ON "product_categories"."id" = "products"."category_id"
  LEFT OUTER JOIN "product_variations" ON "product_variations"."product_id" = "products"."id"
WHERE
  "products"."title" = 'Luxury Shirt'
GROUP BY
  "products"."id"
HAVING
  COUNT("product_variations"."id") > 5
```

There's no distinction between the `WHERE` and `HAVING` clause in the predicate syntax, as it's intended to be easy to
use, but this does come with a caveat.

The query must have all aggregate-modified comparisons before or after non-aggregate-modified comparisons, you can't
mix both.

For example, this query would result in a parsing error: `title ~ Shirt & #variation > 5 & category_name = Shirts`

You can preceed any attribute with one of these aggregate modifier symbols:

- `#` uses the `COUNT` aggregate function
- `+` uses the `MAX` aggregate function
- `-` uses the `MIN` aggregate function
- `*` uses the `SUM` aggregate function
- `~` uses the `AVG` aggregate function

## Development

After checking out the repo, run `bundle exec rake spec` to run the tests.

To install this gem onto your machine, run `bundle exec rake install`.
