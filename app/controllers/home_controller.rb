# frozen_string_literal: true

class HomeController < ApplicationController
  helper HeaderHelper

  def index
    @districts = districts
    @district =  district

    @schools = schools
    @school = school

    @year = year
    @categories = Category.sorted.map { |category| CategoryPresenter.new(category:) }
  end

  private

  def districts
    District.all.order(:name).map do |district|
      [district.name, district.id]
    end
  end

  def district
    return District.first if District.count == 1

    District.find(params[:district]) if params[:district].present?
  end

  def schools
    if district.present?
      district.schools.order(:name).map do |school|
        [school.name, school.id]
      end
    else
      []
    end
  end

  def school
    School.find(params[:school]) if params[:school].present?
  end

  def year
    return nil unless school.present?

    academic_year = AcademicYear.all.order(range: :DESC).find do |ay|
      Subcategory.all.any? do |subcategory|
        rate = subcategory.response_rate(school:, academic_year: ay)
        rate.meets_student_threshold || rate.meets_teacher_threshold
      end
    end

    academic_year&.range || AcademicYear.order("range DESC").first.range
  end
end
