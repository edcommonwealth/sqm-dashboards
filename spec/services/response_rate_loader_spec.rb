require 'rails_helper'

describe ResponseRateLoader do
  let(:school) { School.find_by_slug 'milford-high-school' }
  let(:academic_year) { AcademicYear.find_by_range '2020-21' }
  let(:respondents) do
    respondents = Respondent.where(school:, academic_year:).first
    respondents.total_students = 10
    respondents.total_teachers = 10
    respondents.save
  end

  let(:short_form_survey) do
    survey = Survey.find_by(school:, academic_year:)
    survey.form = :short
    survey.save
    survey
  end

  let(:subcategory) { Subcategory.find_by_subcategory_id '5D' }

  let(:s_acst_q1) { SurveyItem.find_by_survey_item_id 's-acst-q1' }
  let(:s_acst_q2) { SurveyItem.find_by_survey_item_id 's-acst-q2' } # short form
  let(:s_acst_q3) { SurveyItem.find_by_survey_item_id 's-acst-q3' }
  let(:s_poaf_q1) { SurveyItem.find_by_survey_item_id 's-poaf-q1' }
  let(:s_poaf_q2) { SurveyItem.find_by_survey_item_id 's-poaf-q2' }
  let(:s_poaf_q3) { SurveyItem.find_by_survey_item_id 's-poaf-q3' } # short form
  let(:s_poaf_q4) { SurveyItem.find_by_survey_item_id 's-poaf-q4' }
  let(:t_phya_q2) { SurveyItem.find_by_survey_item_id 't-phya-q2' }
  let(:t_phya_q3) { SurveyItem.find_by_survey_item_id 't-phya-q3' }

  let(:s_acst) { Scale.find_by_scale_id 's-acst' }
  let(:s_poaf) { Scale.find_by_scale_id 's-poaf' }
  let(:t_phya) { Scale.find_by_scale_id 't-phya' }

  let(:response_rate) { ResponseRate.find_by(subcategory:, school:, academic_year:) }

  before :each do
    Rails.application.load_seed
    respondents
  end

  after :each do
    DatabaseCleaner.clean
  end

  describe 'self.reset' do
    context 'When resetting response rates' do
      context 'and half the students responded to each question' do
        before :each do
          create_list(:survey_item_response, 5, survey_item: s_acst_q1, likert_score: 3, school:, academic_year:)
          create_list(:survey_item_response, 5, survey_item: s_acst_q2, likert_score: 3, school:, academic_year:)
          create_list(:survey_item_response, 5, survey_item: s_acst_q3, likert_score: 3, school:, academic_year:)
          create_list(:survey_item_response, 5, survey_item: s_poaf_q1, likert_score: 3, school:, academic_year:)
          create_list(:survey_item_response, 5, survey_item: s_poaf_q2, likert_score: 3, school:, academic_year:)
          create_list(:survey_item_response, 5, survey_item: s_poaf_q3, likert_score: 3, school:, academic_year:)
          create_list(:survey_item_response, 5, survey_item: s_poaf_q4, likert_score: 3, school:, academic_year:)
          create_list(:survey_item_response, 5, survey_item: t_phya_q2, likert_score: 3, school:, academic_year:)
          create_list(:survey_item_response, 5, survey_item: t_phya_q3, likert_score: 3, school:, academic_year:)

          ResponseRateLoader.reset(schools: [school], academic_years: [academic_year])
        end

        it 'populates the database with response rates' do
          expect(s_acst_q1.survey_item_id).to eq 's-acst-q1'
          expect(subcategory.subcategory_id).to eq '5D'
          expect(subcategory.name).to eq 'Health'
          expect(s_acst.score(school:, academic_year:)).to eq 3
          expect(s_poaf.score(school:, academic_year:)).to eq 3
          expect(t_phya.score(school:, academic_year:)).to eq 3
          expect(response_rate.student_response_rate).to eq 50
          expect(response_rate.teacher_response_rate).to eq 50
          expect(response_rate.meets_student_threshold).to be true
          expect(response_rate.meets_teacher_threshold).to be true
        end
        context 'when running the loader a second time' do
          it 'is idempotent' do
            response_count = ResponseRate.count
            ResponseRateLoader.reset(schools: [school], academic_years: [academic_year])
            second_count = ResponseRate.count

            expect(response_count).to eq second_count
          end
        end
      end

      context 'and only the first question for each scale was asked; e.g. like on a short form' do
        before :each do
          create_list(:survey_item_response, 5, survey_item: s_acst_q1, likert_score: 3, school:, academic_year:)
          create_list(:survey_item_response, 5, survey_item: s_poaf_q1, likert_score: 3, school:, academic_year:)
          create_list(:survey_item_response, 5, survey_item: t_phya_q2, likert_score: 3, school:, academic_year:)

          ResponseRateLoader.reset(schools: [school], academic_years: [academic_year])
        end

        it 'only takes into account the first question and ignores the other questions in the scale' do
          expect(response_rate.student_response_rate).to eq 50
          expect(response_rate.teacher_response_rate).to eq 50
        end
      end

      context 'and no respondent entry exists for the school and year' do
        before do
          Respondent.destroy_all
          create_list(:survey_item_response, 5, survey_item: s_acst_q1, likert_score: 3, school:, academic_year:)
          create_list(:survey_item_response, 5, survey_item: s_poaf_q1, likert_score: 3, school:, academic_year:)
          create_list(:survey_item_response, 5, survey_item: t_phya_q2, likert_score: 3, school:, academic_year:)

          ResponseRateLoader.reset(schools: [school], academic_years: [academic_year])
        end

        it 'since no score can be calculated, it returns a default of 100' do
          expect(response_rate.student_response_rate).to eq 100
          expect(response_rate.teacher_response_rate).to eq 100
        end
      end

      context 'and the school took the short form student survey' do
        before :each do
          create_list(:survey_item_response, 1, survey_item: s_acst_q1, likert_score: 3, school:, academic_year:)
          create_list(:survey_item_response, 6, survey_item: s_acst_q2, likert_score: 3, school:, academic_year:) # short form
          create_list(:survey_item_response, 1, survey_item: s_acst_q3, likert_score: 3, school:, academic_year:)
          create_list(:survey_item_response, 1, survey_item: s_poaf_q1, likert_score: 3, school:, academic_year:)
          create_list(:survey_item_response, 1, survey_item: s_poaf_q2, likert_score: 3, school:, academic_year:)
          create_list(:survey_item_response, 6, survey_item: s_poaf_q3, likert_score: 3, school:, academic_year:) # short form
          create_list(:survey_item_response, 1, survey_item: s_poaf_q4, likert_score: 3, school:, academic_year:)
          create_list(:survey_item_response, 1, survey_item: t_phya_q2, likert_score: 3, school:, academic_year:)
          create_list(:survey_item_response, 1, survey_item: t_phya_q3, likert_score: 3, school:, academic_year:)
          short_form_survey

          ResponseRateLoader.reset(schools: [school], academic_years: [academic_year])
        end

        it 'only counts responses from survey items on the short form' do
          expect(response_rate.student_response_rate).to eq 60
        end
      end
    end
  end
end
