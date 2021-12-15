require 'rails_helper'

module Legacy
  RSpec.describe DistrictsController, type: :routing do
    describe 'routing' do
      it 'routes to #index' do
        expect(get: '/districts').to route_to('legacy/districts#index')
      end

      it 'routes to #new' do
        expect(get: '/districts/new').to route_to('legacy/districts#new')
      end

      it 'routes to #show' do
        expect(get: '/districts/1').to route_to('legacy/districts#show', id: '1')
      end

      it 'routes to #edit' do
        expect(get: '/districts/1/edit').to route_to('legacy/districts#edit', id: '1')
      end

      it 'routes to #create' do
        expect(post: '/districts').to route_to('legacy/districts#create')
      end

      it 'routes to #update via PUT' do
        expect(put: '/districts/1').to route_to('legacy/districts#update', id: '1')
      end

      it 'routes to #update via PATCH' do
        expect(patch: '/districts/1').to route_to('legacy/districts#update', id: '1')
      end

      it 'routes to #destroy' do
        expect(delete: '/districts/1').to route_to('legacy/districts#destroy', id: '1')
      end
    end
  end
end
