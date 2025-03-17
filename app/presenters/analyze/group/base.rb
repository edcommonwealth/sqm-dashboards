# frozen_string_literal: true

module Analyze
  module Group
    class Base
      attr_reader :name, :slug, :graph

      def initialize(name:, slug:, graph:)
        @name = name
        @slug = slug
        @graph = graph
      end
    end
  end
end
