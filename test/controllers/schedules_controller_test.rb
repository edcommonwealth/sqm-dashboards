require 'test_helper'

class SchedulesControllerTest < ActionController::TestCase
  setup do
    @school = schools(:one)
    @schedule = schedules(:one)
  end

  test "should get index" do
    get :index, params: { school_id: @school }
    assert_response :success
  end

  test "should get new" do
    get :new, params: { school_id: @school }
    assert_response :success
  end

  test "should create schedule" do
    assert_difference('Schedule.count') do
      post :create, params: { school_id: @school, schedule: @schedule.attributes }
    end

    assert_redirected_to school_schedule_path(@school, Schedule.last)
  end

  test "should show schedule" do
    get :show, params: { school_id: @school, id: @schedule }
    assert_response :success
  end

  test "should get edit" do
    get :edit, params: { school_id: @school, id: @schedule }
    assert_response :success
  end

  test "should update schedule" do
    put :update, params: { school_id: @school, id: @schedule, schedule: @schedule.attributes }
    assert_redirected_to school_schedule_path(@school, Schedule.last)
  end

  test "should destroy schedule" do
    assert_difference('Schedule.count', -1) do
      delete :destroy, params: { school_id: @school, id: @schedule }
    end

    assert_redirected_to school_schedules_path(@school)
  end
end
