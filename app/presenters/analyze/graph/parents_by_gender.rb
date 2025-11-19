# frozen_string_literal: true

module Analyze
  module Graph
    class ParentsByGender
      def to_s
        "Parents by Gender"
      end

      def slug
        "parents-by-gender"
      end

      def columns
        [].tap do |array|
          Gender.all.each do |gender|
            label = if gender.designation.match(/\or\s/i)
                      [gender.designation.split("or").first.squish]
                    else
                      gender.designation.split(" ", 2).compact
                    end

            array << Analyze::Graph::Column::Parent::Gender.new(genders: gender, label:, show_irrelevancy_message: false)
          end
          array << Analyze::Graph::Column::Parent::Gender.new(genders: Gender.all, label: ["All Parents"], show_irrelevancy_message: true)
        end
      end

      def source
        Analyze::Source::SurveyData.new(slices: nil, graph: self)
      end

      def slice
        Analyze::Slice::ParentsByGroup.new(graph: self)
      end

      def group
        Analyze::Group::Base.new(name: "Student Gender", slug: "student-gender", graph: self)
      end
    end
  end
end
