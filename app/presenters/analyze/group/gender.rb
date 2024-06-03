module Analyze
  module Group
    class Gender
      def name
        "Gender"
      end

      def slug
        "gender"
      end

      def graph
        Analyze::Graph::StudentsByGender.new(genders: nil)
      end
    end
  end
end
