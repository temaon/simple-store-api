# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Customer cart_items API' do
  let!(:customer) {
    stub_jwt_verification(controller: Api::V1::Customer::InvoicesController, payload: { role: :customer })
  }
  let(:products) { create_list(:product, rand(1..5), owner: create(:user, role: :provider)) }
  let!(:cart_items) {
    customer.cart.cart_items.create(products.sample(3).map { |p| { product_id: p.id, counter: 1 } })
  }

  path '/api/v1/customer/invoices' do

    get 'List of invoices' do
      tags '#index'
      consumes 'application/json'
      security [Bearer: {}]

      response '200', 'Customer able to see the list of invoices' do
        let(:Authorization) { 'Bearer JWT' }
        before do
          customer.cart.generate_latest_invoice(FFaker::Address.street_address)
        end

        run_test! do |response|
          data = JSON.parse(response.body).fetch('data', [])

          expect(data.size).to eq(customer.invoices.count)
        end
      end
    end

    # post 'Add product to favorite list' do
    #   tags '#create'
    #   consumes 'application/json'
    #   security [Bearer: {}]
    #   parameter name: :favorite_params, in: :body, schema: {
    #     type: :object,
    #     properties: {
    #       uuid: {
    #         type: :string,
    #         default: 'uuid'
    #       }
    #     }
    #   }
    #
    #   response '200', 'Customer able to add product to his favorites list' do
    #     let(:Authorization) { 'Bearer JWT' }
    #
    #     let(:product) { create(:product, owner: create(:user, role: :provider)) }
    #
    #     let(:favorite_params) { { favorite: { uuid: product.uuid } } }
    #
    #     run_test! do |response|
    #       data = JSON.parse(response.body).fetch('data', [])
    #
    #       expect(data['id'].to_i).to eq(product.id)
    #     end
    #   end
    # end
  end

  # path '/api/v1/customer/favorites/{id}' do
  #   parameter name: :id, in: :path, type: :string
  #   parameter name: :favorite_params, in: :body, schema: {
  #     type: :object,
  #     properties: {
  #       uuid: {
  #         type: :string,
  #         default: 'uuid'
  #       }
  #     }
  #   }
  #   #
  #   let(:current_product) { products.first }
  #   let(:id) { current_product.uuid }
  #
  #   delete 'Customer able to delete a product from favorite list' do
  #     tags '#destroy'
  #     consumes 'application/json'
  #     security [Bearer: {}]
  #
  #     response '200', 'Product deleting' do
  #       let(:Authorization) { 'Bearer JWT' }
  #       let(:favorite_params) { { favorite: { uuid: current_product.uuid } } }
  #
  #       run_test! do |response|
  #         data = JSON.parse(response.body)
  #         product_uuid = data.dig('data', 'attributes', 'uuid')
  #
  #         expect(current_product.uuid).to eq(product_uuid)
  #       end
  #     end
  #   end
  # end
end
