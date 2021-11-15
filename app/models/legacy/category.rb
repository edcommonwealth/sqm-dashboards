module Legacy
  class Category < ApplicationRecord

    has_many :questions
    belongs_to :parent_category, class_name: 'Legacy::Category', foreign_key: :parent_category_id
    has_many :child_categories, class_name: 'Legacy::Category', foreign_key: :parent_category_id
    has_many :school_categories

    validates :name, presence: true

    scope :for_parent, -> (category = nil) { where(parent_category_id: category.try(:id)) }
    scope :likert, -> { where("benchmark is null") }

    include FriendlyId
    friendly_id :name, :use => [:slugged]

    def path
      p = self
      items = [p]
      items << p while (p = p.try(:parent_category))
      items.uniq.compact.reverse
    end

    def root_identifier
      path.first.name.downcase.gsub(/\s/, '-')
    end

    def root_index
      Category.root_identifiers.index(root_identifier) || 0
    end

    def self.root_identifiers
      [
        "teachers-and-the-teaching-environment",
        "school-culture",
        "resources",
        "academic-learning",
        "community-and-wellbeing",
        "pilot-family-questions"
      ]
    end

    def self.root
      Category.where(parent_category: nil).select { |c| self.root_identifiers.index(c.slug) }
    end

    def custom_zones
      return [] if zones.nil?
      zones.split(",").map(&:to_f)
    end

    def zone_widths
      return nil if zones.nil?

      widths = custom_zones.each_with_index.map do |zone, index|
        (zone - (index == 0 ? 0 : custom_zones[index - 1])).round(2)
      end

      widths[4] = widths[4] + (5 - widths.sum)
      return widths
    end

    def sync_child_zones
      likert_child_categories = child_categories.likert
      return unless likert_child_categories.present?
      total_zones = [0, 0, 0, 0, 0]
      valid_child_categories = 0
      likert_child_categories.each do |cc|
        if cc.zones.nil?
          cc.sync_child_zones
        end

        if cc.zones.nil?
          puts "NO ZONES: #{name} -> #{cc.name}"
        else
          valid_child_categories += 1

          puts "ZONES: #{name} | #{cc.name} | #{cc.zones}"

          cc.custom_zones.each_with_index do |zone, index|
            puts "ZONE: #{name} | #{zone} | #{index}"
            total_zones[index] += zone
          end
        end
      end

      if valid_child_categories > 0
        average_zones = total_zones.map { |zone| zone / valid_child_categories }
        puts "TOTAL: #{name} | #{total_zones} | #{valid_child_categories} | #{average_zones} | #{zone_widths}"
        update(zones: average_zones.join(","))
      end
    end

  end
end
