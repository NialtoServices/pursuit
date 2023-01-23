# frozen_string_literal: true

RSpec.describe Pursuit::Search do
  subject(:search) { described_class.new(search_options) }

  let(:search_options) do
    Pursuit::SearchOptions.new(Product) do |o|
      o.relation :category, :name
      o.relation :variations, :title, :stock_status

      o.attribute :title
      o.attribute :description
      o.attribute :rating, unkeyed: false
      o.attribute :title_length, unkeyed: false do
        Arel::Nodes::NamedFunction.new('LENGTH', [Product.arel_table[:title]])
      end

      o.attribute :cat, :category_id
    end
  end

  describe '#perform' do
    subject(:perform) { search.perform(query) }

    context 'when passed a blank query' do
      let(:query) { '' }

      let(:product_a) { Product.create!(title: 'Alpha') }
      let(:product_b) { Product.create!(title: 'Beta') }

      before do
        product_a
        product_b
      end

      it 'is expected to contain all records' do
        expect(perform).to contain_exactly(product_a, product_b)
      end
    end

    context 'when passed an unkeyed query' do
      let(:query) { 'shirt' }

      let(:product_a) { Product.create!(title: 'Plain Shirt') }
      let(:product_b) { Product.create!(title: 'Funky Shirt') }
      let(:product_c) { Product.create!(title: 'Socks') }

      before do
        product_a
        product_b
        product_c
      end

      it 'is expected to contain the matching records' do
        expect(perform).to contain_exactly(product_a, product_b)
      end
    end

    context 'when passed an `equal to` keyed attribute query' do
      let(:query) { 'title=="Funky Shirt"' }

      let(:product_a) { Product.create!(title: 'Plain Shirt', rating: 2) }
      let(:product_b) { Product.create!(title: 'Funky Shirt', rating: 4) }
      let(:product_c) { Product.create!(title: 'Socks - Pack of 4') }

      before do
        product_a
        product_b
        product_c
      end

      it 'is expected to contain the matching records' do
        expect(perform).to contain_exactly(product_b)
      end
    end

    context 'when passed a `not equal to` keyed attribute query' do
      let(:query) { 'title!="Funky Shirt"' }

      let(:product_a) { Product.create!(title: 'Plain Shirt', rating: 2) }
      let(:product_b) { Product.create!(title: 'Funky Shirt', rating: 4) }
      let(:product_c) { Product.create!(title: 'Socks - Pack of 4') }

      before do
        product_a
        product_b
        product_c
      end

      it 'is expected to contain the matching records' do
        expect(perform).to contain_exactly(product_a, product_c)
      end
    end

    context 'when passed a `match` keyed attribute query' do
      let(:query) { 'title*=shirt' }

      let(:product_a) { Product.create!(title: 'Plain Shirt', rating: 2) }
      let(:product_b) { Product.create!(title: 'Funky Shirt', rating: 4) }
      let(:product_c) { Product.create!(title: 'Socks - Pack of 4') }

      before do
        product_a
        product_b
        product_c
      end

      it 'is expected to contain the matching records' do
        expect(perform).to contain_exactly(product_a, product_b)
      end
    end

    context 'when passed a `not match` keyed attribute query' do
      let(:query) { 'title!*=socks' }

      let(:product_a) { Product.create!(title: 'Plain Shirt', rating: 2) }
      let(:product_b) { Product.create!(title: 'Funky Shirt', rating: 4) }
      let(:product_c) { Product.create!(title: 'Socks - Pack of 4') }

      before do
        product_a
        product_b
        product_c
      end

      it 'is expected to contain the matching records' do
        expect(perform).to contain_exactly(product_a, product_b)
      end
    end

    context 'when passed a numeric `not equal to` keyed attribute query' do
      let(:query) { 'rating!=2' }

      let(:product_a) { Product.create!(title: 'Plain Shirt', rating: 2) }
      let(:product_b) { Product.create!(title: 'Funky Shirt', rating: 4) }
      let(:product_c) { Product.create!(title: 'Socks - Pack of 4', rating: 5) }

      before do
        product_a
        product_b
        product_c
      end

      it 'is expected to contain the matching records' do
        expect(perform).to contain_exactly(product_b, product_c)
      end
    end

    context 'when passed a `greater than` keyed attribute query' do
      let(:query) { 'rating>2' }

      let(:product_a) { Product.create!(title: 'Plain Shirt', rating: 2) }
      let(:product_b) { Product.create!(title: 'Funky Shirt', rating: 4) }
      let(:product_c) { Product.create!(title: 'Socks - Pack of 4', rating: 5) }

      before do
        product_a
        product_b
        product_c
      end

      it 'is expected to contain the matching records' do
        expect(perform).to contain_exactly(product_b, product_c)
      end
    end

    context 'when passed a `greater than or equal to` keyed attribute query' do
      let(:query) { 'rating>=4' }

      let(:product_a) { Product.create!(title: 'Plain Shirt', rating: 2) }
      let(:product_b) { Product.create!(title: 'Funky Shirt', rating: 4) }
      let(:product_c) { Product.create!(title: 'Socks - Pack of 4', rating: 5) }

      before do
        product_a
        product_b
        product_c
      end

      it 'is expected to contain the matching records' do
        expect(perform).to contain_exactly(product_b, product_c)
      end
    end

    context 'when passed a `less than` keyed attribute query' do
      let(:query) { 'rating<5' }

      let(:product_a) { Product.create!(title: 'Plain Shirt', rating: 2) }
      let(:product_b) { Product.create!(title: 'Funky Shirt', rating: 4) }
      let(:product_c) { Product.create!(title: 'Socks - Pack of 4', rating: 5) }

      before do
        product_a
        product_b
        product_c
      end

      it 'is expected to contain the matching records' do
        expect(perform).to contain_exactly(product_a, product_b)
      end
    end

    context 'when passed a `less than or equal to` keyed attribute query' do
      let(:query) { 'rating<=4' }

      let(:product_a) { Product.create!(title: 'Plain Shirt', rating: 2) }
      let(:product_b) { Product.create!(title: 'Funky Shirt', rating: 4) }
      let(:product_c) { Product.create!(title: 'Socks - Pack of 4', rating: 5) }

      before do
        product_a
        product_b
        product_c
      end

      it 'is expected to contain the matching records' do
        expect(perform).to contain_exactly(product_a, product_b)
      end
    end

    context 'when passed a `greater than` and `less than` keyed attribute query' do
      let(:query) { 'rating>2 rating<5' }

      let(:product_a) { Product.create!(title: 'Plain Shirt', rating: 2) }
      let(:product_b) { Product.create!(title: 'Funky Shirt', rating: 4) }
      let(:product_c) { Product.create!(title: 'Socks - Pack of 4', rating: 5) }

      before do
        product_a
        product_b
        product_c
      end

      it 'is expected to contain the matching records' do
        expect(perform).to contain_exactly(product_b)
      end
    end

    context 'when passed a virtual keyed attribute query' do
      let(:query) { 'title_length==5' }

      let(:product_a) { Product.create!(title: 'Plain Shirt') }
      let(:product_b) { Product.create!(title: 'Socks') }

      before do
        product_a
        product_b
      end

      it 'is expected to contain the matching records' do
        expect(perform).to contain_exactly(product_b)
      end
    end

    context 'when querying a custom attribute whose name matches a reflection' do
      let(:query) { 'cat==shirts' }

      let(:shirts_category) { ProductCategory.create!(id: 'shirts', name: 'The Shirt Collection') }
      let(:socks_category)  { ProductCategory.create!(id: 'socks', name: 'The Sock Collection') }

      let(:product_a) { Product.create!(title: 'Plain Shirt', category: shirts_category) }
      let(:product_b) { Product.create!(title: 'Funky Shirt', category: shirts_category) }
      let(:product_c) { Product.create!(title: 'Socks - Pack of 4', category: socks_category) }

      before do
        product_a
        product_b
        product_c
      end

      it 'is expected to contain the matching records' do
        expect(perform).to contain_exactly(product_a, product_b)
      end
    end

    context 'when searching a #has_many relationship' do
      context 'when passed a `match` relationship search query' do
        let(:query) { 'variations*=green' }

        let(:product_a) { Product.create!(title: 'Plain Shirt') }
        let(:product_b) { Product.create!(title: 'Funky Shirt') }

        let(:product_variation_a) { ProductVariation.create!(product: product_a, title: 'Red') }
        let(:product_variation_b) { ProductVariation.create!(product: product_b, title: 'Green') }
        let(:product_variation_c) { ProductVariation.create!(product: product_b, title: 'Blue') }

        before do
          product_a
          product_b

          product_variation_a
          product_variation_b
          product_variation_c
        end

        it 'is expected to contain the matching records' do
          expect(perform).to contain_exactly(product_b)
        end
      end

      context 'when passed an `equal to` relationship count query' do
        let(:query) { 'variations==1' }

        let(:product_a) { Product.create!(title: 'Plain Shirt') }
        let(:product_b) { Product.create!(title: 'Funky Shirt') }
        let(:product_c) { Product.create!(title: 'Socks') }

        let(:product_variation_a) { ProductVariation.create!(product: product_b, title: 'Red') }
        let(:product_variation_b) { ProductVariation.create!(product: product_b, title: 'Green') }
        let(:product_variation_c) { ProductVariation.create!(product: product_b, title: 'Blue') }
        let(:product_variation_d) { ProductVariation.create!(product: product_c, title: 'White') }

        before do
          product_a
          product_b
          product_c

          product_variation_a
          product_variation_b
          product_variation_c
          product_variation_d
        end

        it 'is expected to contain the matching records' do
          expect(perform).to contain_exactly(product_c)
        end
      end

      context 'when passed a `greater than` relationship count query' do
        let(:query) { 'variations>1' }

        let(:product_a) { Product.create!(title: 'Plain Shirt') }
        let(:product_b) { Product.create!(title: 'Funky Shirt') }
        let(:product_c) { Product.create!(title: 'Socks') }

        let(:product_variation_a) { ProductVariation.create!(product: product_b, title: 'Red') }
        let(:product_variation_b) { ProductVariation.create!(product: product_b, title: 'Green') }
        let(:product_variation_c) { ProductVariation.create!(product: product_b, title: 'Blue') }
        let(:product_variation_d) { ProductVariation.create!(product: product_c, title: 'White') }
        let(:product_variation_e) { ProductVariation.create!(product: product_a, title: 'Black') }
        let(:product_variation_f) { ProductVariation.create!(product: product_a, title: 'Gray') }

        before do
          product_a
          product_b
          product_c

          product_variation_a
          product_variation_b
          product_variation_c
          product_variation_d
          product_variation_e
          product_variation_f
        end

        it 'is expected to contain the matching records' do
          expect(perform).to contain_exactly(product_a, product_b)
        end
      end

      context 'when passed a `greater than or equal to` relationship count query' do
        let(:query) { 'variations>=2' }

        let(:product_a) { Product.create!(title: 'Plain Shirt') }
        let(:product_b) { Product.create!(title: 'Funky Shirt') }
        let(:product_c) { Product.create!(title: 'Socks') }

        let(:product_variation_a) { ProductVariation.create!(product: product_b, title: 'Red') }
        let(:product_variation_b) { ProductVariation.create!(product: product_b, title: 'Green') }
        let(:product_variation_c) { ProductVariation.create!(product: product_b, title: 'Blue') }
        let(:product_variation_d) { ProductVariation.create!(product: product_c, title: 'White') }
        let(:product_variation_e) { ProductVariation.create!(product: product_a, title: 'Black') }
        let(:product_variation_f) { ProductVariation.create!(product: product_a, title: 'Gray') }

        before do
          product_a
          product_b
          product_c

          product_variation_a
          product_variation_b
          product_variation_c
          product_variation_d
          product_variation_e
          product_variation_f
        end

        it 'is expected to contain the matching records' do
          expect(perform).to contain_exactly(product_a, product_b)
        end
      end

      context 'when passed a `less than` relationship count query' do
        let(:query) { 'variations<3' }

        let(:product_a) { Product.create!(title: 'Plain Shirt') }
        let(:product_b) { Product.create!(title: 'Funky Shirt') }
        let(:product_c) { Product.create!(title: 'Socks') }

        let(:product_variation_a) { ProductVariation.create!(product: product_b, title: 'Red') }
        let(:product_variation_b) { ProductVariation.create!(product: product_b, title: 'Green') }
        let(:product_variation_c) { ProductVariation.create!(product: product_b, title: 'Blue') }
        let(:product_variation_d) { ProductVariation.create!(product: product_c, title: 'White') }
        let(:product_variation_e) { ProductVariation.create!(product: product_a, title: 'Black') }
        let(:product_variation_f) { ProductVariation.create!(product: product_a, title: 'Gray') }

        before do
          product_a
          product_b
          product_c

          product_variation_a
          product_variation_b
          product_variation_c
          product_variation_d
          product_variation_e
          product_variation_f
        end

        it 'is expected to contain the matching records' do
          expect(perform).to contain_exactly(product_a, product_c)
        end
      end

      context 'when passed a `less than or equal to` relationship count query' do
        let(:query) { 'variations<=2' }

        let(:product_a) { Product.create!(title: 'Plain Shirt') }
        let(:product_b) { Product.create!(title: 'Funky Shirt') }
        let(:product_c) { Product.create!(title: 'Socks') }

        let(:product_variation_a) { ProductVariation.create!(product: product_b, title: 'Red') }
        let(:product_variation_b) { ProductVariation.create!(product: product_b, title: 'Green') }
        let(:product_variation_c) { ProductVariation.create!(product: product_b, title: 'Blue') }
        let(:product_variation_d) { ProductVariation.create!(product: product_c, title: 'White') }
        let(:product_variation_e) { ProductVariation.create!(product: product_a, title: 'Black') }
        let(:product_variation_f) { ProductVariation.create!(product: product_a, title: 'Gray') }

        before do
          product_a
          product_b
          product_c

          product_variation_a
          product_variation_b
          product_variation_c
          product_variation_d
          product_variation_e
          product_variation_f
        end

        it 'is expected to contain the matching records' do
          expect(perform).to contain_exactly(product_a, product_c)
        end
      end

      context 'when passed a `greater than` and `less than` relationship count query' do
        let(:query) { 'variations>1 variations<3' }

        let(:product_a) { Product.create!(title: 'Plain Shirt') }
        let(:product_b) { Product.create!(title: 'Funky Shirt') }
        let(:product_c) { Product.create!(title: 'Socks') }

        let(:product_variation_a) { ProductVariation.create!(product: product_b, title: 'Red') }
        let(:product_variation_b) { ProductVariation.create!(product: product_b, title: 'Green') }
        let(:product_variation_c) { ProductVariation.create!(product: product_b, title: 'Blue') }
        let(:product_variation_d) { ProductVariation.create!(product: product_c, title: 'White') }
        let(:product_variation_e) { ProductVariation.create!(product: product_a, title: 'Black') }
        let(:product_variation_f) { ProductVariation.create!(product: product_a, title: 'Gray') }

        before do
          product_a
          product_b
          product_c

          product_variation_a
          product_variation_b
          product_variation_c
          product_variation_d
          product_variation_e
          product_variation_f
        end

        it 'is expected to contain the matching records' do
          expect(perform).to contain_exactly(product_a)
        end
      end
    end

    context 'when searching a #belongs_to relationship' do
      context 'when passed a `match` relationship search query' do
        let(:query) { 'category*=shirt' }

        let(:product_category_a) { ProductCategory.create!(id: 'one', name: 'Shirts') }
        let(:product_category_b) { ProductCategory.create!(id: 'two', name: 'Socks') }

        let(:product_a) { Product.create!(category: product_category_a, title: 'Plain Shirt') }
        let(:product_b) { Product.create!(category: product_category_a, title: 'Funky Shirt') }
        let(:product_c) { Product.create!(category: product_category_b, title: 'White Socks') }

        before do
          product_category_a
          product_category_b

          product_a
          product_b
          product_c
        end

        it 'is expected to contain the matching records' do
          expect(perform).to contain_exactly(product_a, product_b)
        end
      end
    end
  end
end
