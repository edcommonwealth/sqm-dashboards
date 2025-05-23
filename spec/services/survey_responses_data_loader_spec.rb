require "rails_helper"

describe SurveyResponsesDataLoader do
  let(:path_to_teacher_responses) { Rails.root.join("spec", "fixtures", "test_2020-21_teacher_survey_responses.csv") }
  let(:path_to_student_responses) { Rails.root.join("spec", "fixtures", "test_2020-21_student_survey_responses.csv") }
  let(:path_to_parent_responses) { Rails.root.join("spec", "fixtures", "test_2020-21_parent_survey_responses.csv") }
  let(:path_to_butler_student_responses) do
    Rails.root.join("spec", "fixtures", "test_2022-23_butler_student_survey_responses.csv")
  end

  let(:ay_2020_21) { create(:academic_year, range: "2020-21") }
  let(:ay_2022_23) { create(:academic_year, range: "2022-23") }

  let(:school) { create(:school, name: "Lee Elementary School", slug: "lee-elementary-school", dese_id: 1_500_025) }
  let(:lowell) { create(:district, name: "Lowell", slug: "lowell") }
  let(:second_school) do
    create(:school, name: "Lee Middle High School", slug: "lee-middle-high-school", dese_id: 1_500_505,
                    district: lowell)
  end
  let(:butler_school) do
    create(:school, name: "Butler Elementary School", slug: "butler-elementary-school", dese_id: 1_600_310,
                    district: lowell)
  end

  let(:student_survey_items) do
    ids = %w[ s-emsa-q1 s-emsa-q2 s-emsa-q3
              s-tint-q1 s-tint-q2 s-tint-q4 s-tint-q5
              s-acpr-q1 s-acpr-q2 s-acpr-q3 s-acpr-q4
              s-cure-q3 s-cure-q4 s-sten-q2 s-sten-q3
              s-sper-q1 s-sper-q2 s-sper-q3 s-sper-q4
              s-civp-q1 s-civp-q2 s-civp-q3 s-civp-q4 s-grmi-q1
              s-grmi-q4 s-appa-q1
              s-appa-q2 s-peff-q1
              s-peff-q2 s-peff-q3 s-peff-q4 s-peff-q5 s-peff-q6
              s-sbel-q1 s-sbel-q2 s-sbel-q3 s-sbel-q4 s-sbel-q5
              s-phys-q1 s-phys-q2 s-phys-q3 s-phys-q4
              s-vale-q1 s-vale-q2 s-vale-q3 s-vale-q4
              s-acst-q1 s-acst-q2 s-acst-q3 s-acst-q4 s-acst-q5
              s-grit-q1 s-grit-q2 s-grit-q3 s-grit-q4]

    ids.each do |id|
      create(:survey_item, survey_item_id: id)
    end
  end
  let(:parent_survey_items) do
    ids = %w[
      p-socx-q1
      p-socx-q2
      p-socx-q3
      p-socx-q4
      p-sosu-q1
      p-sosu-q2
      p-sosu-q3
      p-sosu-q4
      p-tcom-q1
      p-tcom-q2
      p-tcom-q3
      p-comm-q1
      p-comm-q2
      p-comm-q3
      p-comm-q4
      p-valm-q1
      p-valm-q2
      p-valm-q3
      p-valm-q4
      p-acpr-q1
      p-acpr-q2
      p-acpr-q3
      p-acpr-q4
    ]

    ids.each do |id|
      create(:survey_item, survey_item_id: id)
    end
  end

  let(:vestigial_parent_ids) do
    %w[
      p-scrp-q3
      p-cure-q1
      p-cure-q2
      p-cure-q3
      p-cure-q4
      p-evnt-q1
      p-evnt-q2
      p-evnt-q3
      p-evnt-q4
      p-phys-q3
      p-scrp-q1
      p-scrp-q2
    ]
  end

  let(:housings) do
    create(:housing, designation: "Own")
    create(:housing, designation: "Rent")
    create(:housing, designation: "Unknown")
  end

  let(:t_pcom_q3) { create(:survey_item, survey_item_id: "t-pcom-q3") }
  let(:t_pcom_q2) { create(:survey_item, survey_item_id: "t-pcom-q2") }
  let(:t_coll_q1) { create(:survey_item, survey_item_id: "t-coll-q1") }
  let(:t_coll_q2) { create(:survey_item, survey_item_id: "t-coll-q2") }
  let(:t_coll_q3) { create(:survey_item, survey_item_id: "t-coll-q3") }
  let(:t_sach_q1) { create(:survey_item, survey_item_id: "t-sach-q1") }
  let(:t_sach_q2) { create(:survey_item, survey_item_id: "t-sach-q2") }
  let(:t_sach_q3) { create(:survey_item, survey_item_id: "t-sach-q3") }

  let(:female) { create(:gender, qualtrics_code: 1) }
  let(:male) { create(:gender, qualtrics_code: 2) }
  let(:another_gender) { create(:gender, qualtrics_code: 3) }
  let(:non_binary) { create(:gender, qualtrics_code: 4) }
  let(:unknown_gender) { create(:gender, qualtrics_code: 99) }

  let(:low_income) { create(:income, designation: "Economically Disadvantaged – Y") }
  let(:high_income) { create(:income, designation: "Economically Disadvantaged – N") }
  let(:unknown_income) { create(:income, designation: "Unknown") }

  let(:yes_ell) { create(:ell, designation: "ELL") }
  let(:not_ell) { create(:ell, designation: "Not ELL") }
  let(:unknown_ell) { create(:ell, designation: "Unknown") }

  let(:american_indian) { create(:race, qualtrics_code: 1, designation: "American Indian or Alaskan Native") }
  let(:asian)           { create(:race, qualtrics_code: 2, designation: "Asian or Pacific Islander") }
  let(:black)           { create(:race, qualtrics_code: 3, designation: "Black or African American") }
  let(:latinx)          { create(:race, qualtrics_code: 4, designation: "Hispanic or Latinx") }
  let(:white)           { create(:race, qualtrics_code: 5, designation: "White or Caucasian") }
  let(:middle_eastern)  { create(:race, qualtrics_code: 8, designation: "Middle Eastern") }
  let(:unknown_race)    { create(:race, qualtrics_code: 99, designation: "Race/Ethnicity Not Listed") }
  let(:multiracial)     { create(:race, qualtrics_code: 100, designation: "Multiracial") }

  let(:languages) do
    create(:language, designation: "English")
    create(:language, designation: "Spanish")
    create(:language, designation: "Portuguese")
    create(:language, designation: "Unknown")
  end

  let(:setup) do
    ay_2020_21
    ay_2022_23
    school
    second_school
    butler_school
    housings
    t_pcom_q3
    t_pcom_q2
    t_coll_q1
    t_coll_q2
    t_coll_q3
    t_sach_q1
    t_sach_q2
    t_sach_q3
    student_survey_items

    female
    male
    another_gender
    non_binary
    unknown_gender

    low_income
    high_income
    unknown_income

    yes_ell
    not_ell
    unknown_ell

    american_indian
    asian
    black
    latinx
    white
    middle_eastern
    unknown_race
    multiracial

    languages
  end

  before :each do
    setup
  end

  describe "loading teacher survey responses" do
    before do
      SurveyResponsesDataLoader.new.load_data filepath: path_to_teacher_responses
    end

    it "ensures teacher responses load correctly" do
      assigns_academic_year_to_survey_item_responses
      assigns_school_to_the_survey_item_responses
      assigns_recorded_date_to_teacher_responses
      loads_survey_item_responses_for_a_given_survey_response
      loads_all_survey_item_responses_for_a_given_survey_item
      captures_likert_scores_for_survey_item_responses
      is_idempotent
    end
  end

  describe "student survey responses" do
    before do
      SurveyResponsesDataLoader.new.load_data filepath: path_to_student_responses
    end

    it "ensures student responses load correctly" do
      assigns_academic_year_to_student_survey_item_responses
      assigns_school_to_student_survey_item_responses
      assigns_recorded_date_to_student_responses
      loads_student_survey_item_response_values
      student_survey_item_response_count_matches_expected
      captures_likert_scores_for_student_survey_item_responses
      assigns_grade_level_to_responses
      assigns_gender_to_responses
      assigns_income_to_responses
      assigns_ell_to_responses
      assigns_races_to_students
      is_idempotent_for_students
    end

    context "when updating student survey responses from another csv file" do
      before :each do
        SurveyResponsesDataLoader.new.load_data filepath: Rails.root.join("spec", "fixtures",
                                                                          "secondary_test_2020-21_student_survey_responses.csv")
      end
      it "updates the likert score to the score on the new csv file" do
        s_emsa_q1 = SurveyItem.find_by_survey_item_id "s-emsa-q1"
        s_acst_q3 = SurveyItem.find_by_survey_item_id "s-acst-q3"
        expect(SurveyItemResponse.where(response_id: "student_survey_response_3",
                                        survey_item: s_emsa_q1).first.likert_score).to eq 1
        expect(SurveyItemResponse.where(response_id: "student_survey_response_4",
                                        survey_item: s_emsa_q1).first.likert_score).to eq 1
        expect(SurveyItemResponse.where(response_id: "student_survey_response_5",
                                        survey_item: s_emsa_q1).first.likert_score).to eq 1

        expect(SurveyItemResponse.where(response_id: "student_survey_response_5",
                                        survey_item: s_acst_q3).first.likert_score).to eq 4
      end
    end
  end

  describe "parent survey responses" do
    before do
      school
      ay_2020_21
      parent_survey_items
      SurveyResponsesDataLoader.new.load_data filepath: path_to_parent_responses
    end

    it "adds only the surveyitems that exist in source of truth" do
      si = (SurveyItemResponse.where(school:, response_id: "parent_survey_response_1").map do |response|
        response.survey_item.survey_item_id
      end)
      response_ids = %w[
        parent_survey_response_1
        parent_survey_response_2
        parent_survey_response_3
        parent_survey_response_4
        parent_survey_response_5
        parent_survey_response_6
      ]
      response_ids.each do |id|
        expect(SurveyItemResponse.where(response_id: id,
                                        survey_item: SurveyItem.parent_survey_items).count).to eq 23
      end

      expect(SurveyItemResponse.where(response_id: "parent_survey_response_8").count).to eq 0
    end

    it "does not add surveyitems from questions that have been disabled" do
      vestigial_parent_ids.each do |id|
        expect(SurveyItemResponse.where(school:, survey_item: id).count).to eq 0
      end
    end

    it "loads the correct set of races for parents" do
      assigns_races_to_parents
    end

    it "loads the correct set of genders for parents" do
      assigns_genders_to_parents
    end
  end
end

def assigns_academic_year_to_survey_item_responses
  expect(SurveyItemResponse.find_by_response_id("teacher_survey_response_1").academic_year).to eq ay_2020_21
end

def assigns_school_to_the_survey_item_responses
  expect(SurveyItemResponse.find_by_response_id("teacher_survey_response_1").school).to eq school
end

def loads_survey_item_responses_for_a_given_survey_response
  expect(SurveyItemResponse.where(response_id: "teacher_survey_response_1").count).to eq 5
  expect(SurveyItemResponse.where(response_id: "teacher_survey_response_2").count).to eq 0
  expect(SurveyItemResponse.where(response_id: "teacher_survey_response_3").count).to eq 8
  expect(SurveyItemResponse.where(response_id: "teacher_survey_response_4").count).to eq 8
  expect(SurveyItemResponse.where(response_id: "teacher_survey_response_5").count).to eq 8
end

def loads_all_survey_item_responses_for_a_given_survey_item
  expect(SurveyItemResponse.where(survey_item: t_pcom_q2).count).to eq 3
  expect(SurveyItemResponse.where(survey_item: t_pcom_q3).count).to eq 4
end

def captures_likert_scores_for_survey_item_responses
  expect(SurveyItemResponse.where(response_id: "teacher_survey_response_1").where(survey_item: t_pcom_q2)).to be_empty
  expect(SurveyItemResponse.where(response_id: "teacher_survey_response_1").where(survey_item: t_pcom_q3).first.likert_score).to eq 3

  expect(SurveyItemResponse.where(response_id: "teacher_survey_response_2").where(survey_item: t_pcom_q2)).to be_empty
  expect(SurveyItemResponse.where(response_id: "teacher_survey_response_2").where(survey_item: t_pcom_q3)).to be_empty

  expect(SurveyItemResponse.where(response_id: "teacher_survey_response_3").where(survey_item: t_pcom_q2).first.likert_score).to eq 5
  expect(SurveyItemResponse.where(response_id: "teacher_survey_response_3").where(survey_item: t_pcom_q3).first.likert_score).to eq 5

  expect(SurveyItemResponse.where(response_id: "teacher_survey_response_4").where(survey_item: t_pcom_q2).first.likert_score).to eq 4
  expect(SurveyItemResponse.where(response_id: "teacher_survey_response_4").where(survey_item: t_pcom_q3).first.likert_score).to eq 4

  expect(SurveyItemResponse.where(response_id: "teacher_survey_response_5").where(survey_item: t_pcom_q2).first.likert_score).to eq 2
  expect(SurveyItemResponse.where(response_id: "teacher_survey_response_5").where(survey_item: t_pcom_q3).first.likert_score).to eq 4
end

def is_idempotent
  number_of_survey_item_responses = SurveyItemResponse.count

  SurveyResponsesDataLoader.new.load_data filepath: path_to_teacher_responses

  expect(SurveyItemResponse.count).to eq number_of_survey_item_responses
end

def assigns_academic_year_to_student_survey_item_responses
  expect(SurveyItemResponse.find_by_response_id("student_survey_response_3").academic_year).to eq ay_2020_21
end

def assigns_school_to_student_survey_item_responses
  expect(SurveyItemResponse.find_by_response_id("student_survey_response_3").school).to eq second_school
end

def loads_student_survey_item_response_values
  expect(SurveyItemResponse.where(response_id: "student_survey_response_1").count).to eq 3
  expect(SurveyItemResponse.where(response_id: "student_survey_response_2").count).to eq 0
  expect(SurveyItemResponse.where(response_id: "student_survey_response_3").count).to eq 30
  expect(SurveyItemResponse.where(response_id: "student_survey_response_4").count).to eq 27
  expect(SurveyItemResponse.where(response_id: "student_survey_response_5").count).to eq 30
end

def student_survey_item_response_count_matches_expected
  s_phys_q1 = SurveyItem.where(survey_item_id: "s-phys-q1")
  s_phys_q2 = SurveyItem.where(survey_item_id: "s-phys-q2")
  expect(SurveyItemResponse.where(survey_item: s_phys_q1).count).to eq 6
  expect(SurveyItemResponse.where(survey_item: s_phys_q2).count).to eq 5
end

def captures_likert_scores_for_student_survey_item_responses
  s_phys_q1 = SurveyItem.where(survey_item_id: "s-phys-q1")
  s_phys_q2 = SurveyItem.where(survey_item_id: "s-phys-q2")
  expect(SurveyItemResponse.where(response_id: "student_survey_response_1").where(survey_item: s_phys_q1).first.likert_score).to eq 3
  expect(SurveyItemResponse.where(response_id: "student_survey_response_1").where(survey_item: s_phys_q2)).to be_empty

  expect(SurveyItemResponse.where(response_id: "student_survey_response_2").where(survey_item: s_phys_q1)).to be_empty
  expect(SurveyItemResponse.where(response_id: "student_survey_response_2").where(survey_item: s_phys_q2)).to be_empty

  expect(SurveyItemResponse.where(response_id: "student_survey_response_3").where(survey_item: s_phys_q1).first.likert_score).to eq 1
  expect(SurveyItemResponse.where(response_id: "student_survey_response_3").where(survey_item: s_phys_q2).first.likert_score).to eq 3

  expect(SurveyItemResponse.where(response_id: "student_survey_response_4").where(survey_item: s_phys_q1).first.likert_score).to eq 1
  expect(SurveyItemResponse.where(response_id: "student_survey_response_4").where(survey_item: s_phys_q2).first.likert_score).to eq 1

  expect(SurveyItemResponse.where(response_id: "student_survey_response_5").where(survey_item: s_phys_q1).first.likert_score).to eq 1
  expect(SurveyItemResponse.where(response_id: "student_survey_response_5").where(survey_item: s_phys_q2).first.likert_score).to eq 2
end

def is_idempotent_for_students
  number_of_survey_item_responses = SurveyItemResponse.count

  SurveyResponsesDataLoader.new.load_data filepath: path_to_student_responses

  expect(SurveyItemResponse.count).to eq number_of_survey_item_responses
end

def assigns_grade_level_to_responses
  results = { "student_survey_response_1" => 11,
              "student_survey_response_3" => 8,
              "student_survey_response_4" => 8,
              "student_survey_response_5" => 7,
              "student_survey_response_6" => 3,
              "student_survey_response_7" => 4 }
  results.each do |key, value|
    expect(SurveyItemResponse.where(response_id: key).all? do |response|
      response.grade == value
    end).to eq true
  end
end

def assigns_gender_to_responses
  results = { "student_survey_response_1" => female,
              "student_survey_response_3" => male,
              "student_survey_response_4" => non_binary,
              "student_survey_response_5" => non_binary,
              "student_survey_response_6" => unknown_gender,
              "student_survey_response_7" => non_binary }

  results.each do |key, value|
    expect(SurveyItemResponse.where(response_id: key).first.gender).to eq value
  end
end

def assigns_recorded_date_to_student_responses
  results = { "student_survey_response_1" => "2020-09-30T18:48:50",
              "student_survey_response_3" => "2021-03-31T09:59:02",
              "student_survey_response_4" => "2021-03-31T10:00:17",
              "student_survey_response_5" => "2021-03-31T10:01:36",
              "student_survey_response_6" => "2021-03-31T10:01:37",
              "student_survey_response_7" => "2021-03-31T10:01:38" }
  results.each do |key, value|
    expect(SurveyItemResponse.find_by_response_id(key).recorded_date).to eq Date.parse(value)
  end
end

def assigns_recorded_date_to_teacher_responses
  results = { "teacher_survey_response_1" => "2020-10-16T11:09:03",
              "teacher_survey_response_3" => "2020-12-06T8:36:52",
              "teacher_survey_response_4" => "2020-12-06T8:51:25",
              "teacher_survey_response_5" => "2020-12-06T8:55:58" }
  results.each do |key, value|
    expect(SurveyItemResponse.find_by_response_id(key).recorded_date).to eq Date.parse(value)
  end
end

def assigns_income_to_responses
  results = { "student_survey_response_1" => low_income,
              "student_survey_response_3" => low_income,
              "student_survey_response_4" => high_income,
              "student_survey_response_5" => low_income,
              "student_survey_response_6" => high_income,
              "student_survey_response_7" => low_income }

  results.each do |key, value|
    income = SurveyItemResponse.find_by_response_id(key).income
    expect(income).to eq value
  end
end

def assigns_ell_to_responses
  results = { "student_survey_response_1" => not_ell,
              "student_survey_response_3" => not_ell,
              "student_survey_response_4" => yes_ell,
              "student_survey_response_5" => yes_ell,
              "student_survey_response_6" => unknown_ell,
              "student_survey_response_7" => unknown_ell }

  results.each do |key, value|
    ell = SurveyItemResponse.find_by_response_id(key).ell
    expect(ell).to eq value
  end
end

def assigns_races_to_students
  results = {  "student_survey_response_1" => [american_indian],
               "student_survey_response_3" => [asian, black, latinx, multiracial],
               "student_survey_response_4" => [unknown_race],
               "student_survey_response_5" => [american_indian, asian, black, latinx, white, middle_eastern,
                                               multiracial],
               "student_survey_response_6" => [american_indian, asian, black, latinx, white, middle_eastern,
                                               multiracial],
               "student_survey_response_7" => [white] }

  results.each do |key, value|
    race = SurveyItemResponse.find_by_response_id(key).student.races.to_a
    qualtrics = race.map(&:qualtrics_code)
    expect(race).to eq value
  end
end

def assigns_races_to_parents
  results = {
    "parent_survey_response_1" => [american_indian],
    "parent_survey_response_2" => [unknown_race],
    "parent_survey_response_3" => [american_indian, latinx, white, multiracial],
    "parent_survey_response_4" => [unknown_race],
    "parent_survey_response_5" => [american_indian, asian, black, latinx, white, middle_eastern,
                                   multiracial],
    "parent_survey_response_6" => [american_indian, asian, black, latinx, white, middle_eastern,
                                   multiracial],
    "parent_survey_response_7" => [white]
  }

  results.each do |key, value|
    race = SurveyItemResponse.find_by_response_id(key).parent.races.to_a
    qualtrics = race.map(&:qualtrics_code).sort
    expect(race).to eq value
  end
end

def assigns_genders_to_parents
  results = { "parent_survey_response_1" => [male],
              "parent_survey_response_2" => [female],
              "parent_survey_response_3" => [female, male],
              "parent_survey_response_4" => [non_binary],
              "parent_survey_response_5" => [male],
              "parent_survey_response_6" => [unknown_gender] }
  # "parent_survey_response_7" => [non_binary] }

  results.each do |key, value|
    expect(SurveyItemResponse.where(response_id: key).first.parent.genders).to eq value
  end
end
