module Analyze
  module Group
    class Ell
      def name
        "ELL"
      end

      def slug
        "ell"
      end

      def graph
        Analyze::Graph::StudentsByEll.new(ells: nil)
      end
    end
  end
end
