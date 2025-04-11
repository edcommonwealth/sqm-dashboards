# frozen_string_literal: true

module Analyze
  module Graph
    class ParentsByLanguage
      attr_reader :speds

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
          array << Analyze::Graph::Column::Language.new(languages: ENGLISH_LANGUAGES, label: ["English", "Speaking"])
          array << Analyze::Graph::Column::Language.new(languages: NON_ENGLISH_LANGUAGES, label: ["Non English", "Speaking"])
          array << Analyze::Graph::Column::Language.new(languages: UNKNOWN_LANGUAGES, label: ["Unknown"])
          array << Analyze::Graph::Column::Language.new(languages: ALL_LANGUAGES, label: ["All", "Parents"])
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
