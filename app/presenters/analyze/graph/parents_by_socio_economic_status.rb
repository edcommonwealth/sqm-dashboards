# frozen_string_literal: true

module Analyze
  module Graph
    class ParentsBySocioEconomicStatus
      def to_s
        "Parents by Socio-Economic Status"
      end

      def slug
        "parents-by-socio-economic-status"
      end

      def columns
        [].tap do |array|
          array << Analyze::Graph::Column::Parent::SocioEconomicStatus.new(socio_economic_status: [0, 1], label: ["Low Advantage"], show_irrelevancy_message: false)
          array << Analyze::Graph::Column::Parent::SocioEconomicStatus.new(socio_economic_status: 2, label: ["Mediumn Advantage"], show_irrelevancy_message: false)
          array << Analyze::Graph::Column::Parent::SocioEconomicStatus.new(socio_economic_status: 3, label: ["High Advantage"], show_irrelevancy_message: false)

          array << Analyze::Graph::Column::Parent::SocioEconomicStatus.new(socio_economic_status: [0, 1, 2, 3, nil], label: ["All Students"], show_irrelevancy_message: true)
        end
      end

      def source
        Analyze::Source::SurveyData.new(slices: nil, graph: self)
      end

      def slice
        Analyze::Slice::ParentsByGroup.new(graph: self)
      end

      def group
        Analyze::Group::Base.new(name: "Parents By Socio-Economic Status", slug: "parents-by-socio-economic-status", graph: self)
      end
    end
  end
end
