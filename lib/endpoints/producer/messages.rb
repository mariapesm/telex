module Endpoints
  class Producer::Messages < Base
    namespace "/messages" do
      before do
        content_type :json, charset: 'utf-8'
      end

      post do
        creator = Mediators::Messages::Creator.new(
          producer: current_producer,
          title:       data['title'],
          body:        data['body'],
          target_type: data['target']['type'],
          target_id:   data['target']['id']
        )

        message = creator.call
        status 201
        MultiJson.encode({id: message.uuid})
      end

    end

    private

    def data
      MultiJson.decode(request.body.read).tap do
        request.body.rewind
      end
    end

    def current_producer
      Pliny::RequestStore.store.fetch(:current_producer)
    end

  end
end
