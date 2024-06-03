module Analyze
  module Group
    class Sped
      def name
        "Special Education"
      end

      def slug
        "sped"
      end

      def graph
        Analyze::Graph::StudentsBySped.new(speds: nil)
      end
    end
  end
end

