# frozen_string_literal: true

class Scale < ApplicationRecord
  belongs_to :measure, counter_cache: true
  has_one :category, through: :measure
  has_many :survey_items
  has_many :survey_item_responses, through: :survey_items
  has_many :admin_data_items

  def score(school:, academic_year:)
    @score ||= Hash.new do |memo, (school, academic_year)|
      memo[[school, academic_year]] = begin
        items = []
        items << collect_survey_item_average(student_survey_items, school, academic_year)
        items << collect_survey_item_average(teacher_survey_items, school, academic_year)

        items.remove_blanks.average
      end
    end
    @score[[school, academic_year]]
  end

  def parent_score(school:, academic_year:)
    @parent_score ||= Hash.new do |memo, (school, academic_year)|
      memo[[school, academic_year]] = begin
        items = []
        items << collect_survey_item_average(survey_items.parent_survey_items, school, academic_year)

        items.remove_blanks.average
      end
    end
    @parent_score[[school, academic_year]]
  end

  scope :teacher_scales, lambda {
    where("scale_id LIKE 't-%'")
  }
  scope :student_scales, lambda {
    where("scale_id LIKE 's-%'")
  }
  scope :parent_scales, lambda {
    where("scale_id LIKE 'p-%'")
  }

  def watch_low_benchmark
    survey_items.first.watch_low_benchmark
  end

  def growth_low_benchmark
    survey_items.first.growth_low_benchmark
  end

  def approval_low_benchmark
    survey_items.first.approval_low_benchmark
  end

  def ideal_low_benchmark
    survey_items.first.ideal_low_benchmark
  end

  def includes_teacher_survey_items?
    survey_items.teacher_survey_items.length.positive?
  end

  def includes_student_survey_items?
    survey_items.student_survey_items.length.positive?
  end

  def includes_admin_data_items?
    admin_data_items.length.positive?
  end

  def construct_id
    scale_id
  end

  private

  def collect_survey_item_average(survey_items, school, academic_year)
    survey_items.map do |survey_item|
      survey_item.score(school:, academic_year:)
    end.remove_blanks.average
  end

  def teacher_survey_items
    survey_items.teacher_survey_items
  end

  def student_survey_items
    survey_items.student_survey_items
  end
end
