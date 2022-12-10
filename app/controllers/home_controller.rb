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
    latest_response_rate = ResponseRate.where(school:)
                                       .where('meets_student_threshold = ? or meets_teacher_threshold = ?', true, true)
                                       .joins('inner join academic_years a on response_rates.academic_year_id=a.id')
                                       .order('a.range DESC').first
    academic_year = latest_response_rate.academic_year.range if latest_response_rate.present?

    academic_year || AcademicYear.order('range DESC').first.range
  end
end
