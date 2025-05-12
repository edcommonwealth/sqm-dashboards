# frozen_string_literal: true

module Analyze
  module Graph
    class ParentsByLanguage
      ALL_LANGUAGES = Language.all
      ENGLISH_LANGUAGES = ALL_LANGUAGES.select { |language| language.designation == "English" }
      UNKNOWN_LANGUAGES = ALL_LANGUAGES.select { |language| language.designation == "Prefer not to disclose" }
      NON_ENGLISH_LANGUAGES = (ALL_LANGUAGES - ENGLISH_LANGUAGES - UNKNOWN_LANGUAGES)

      def to_s
        "Parents by Language"
      end

      def slug
        "parents-by-language"
      end

      def columns
        [].tap do |array|
          array << Analyze::Graph::Column::Parent::Language.new(languages: ENGLISH_LANGUAGES, label: ["English", "Speaking"], show_irrelevancy_message: false)
          array << Analyze::Graph::Column::Parent::Language.new(languages: NON_ENGLISH_LANGUAGES, label: ["Non English", "Speaking"], show_irrelevancy_message: false)
          array << Analyze::Graph::Column::Parent::Language.new(languages: UNKNOWN_LANGUAGES, label: ["Unknown"], show_irrelevancy_message: false)
          array << Analyze::Graph::Column::Parent::Language.new(languages: ALL_LANGUAGES, label: ["All", "Parents"], show_irrelevancy_message: nil)
        end
      end

      def source
        Analyze::Source::SurveyData.new(slices: nil, graph: self)
      end

      def slice
        Analyze::Slice::ParentsByGroup.new(graph: self)
      end

      def group
        Analyze::Group::Base.new(name: "Language", slug: "language", graph: self)
      end
    end
  end
end
