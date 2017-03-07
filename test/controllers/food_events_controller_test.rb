require 'test_helper'

class FoodEventsControllerTest < ActionController::TestCase
  setup do
    @food_event = food_events(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:food_events)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create food_event" do
    assert_difference('FoodEvent.count') do
      post :create, food_event: { akbar_present: @food_event.akbar_present, amar_present: @food_event.amar_present, anthony_present: @food_event.anthony_present, name: @food_event.name }
    end

    assert_redirected_to food_event_path(assigns(:food_event))
  end

  test "should show food_event" do
    get :show, id: @food_event
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @food_event
    assert_response :success
  end

  test "should update food_event" do
    patch :update, id: @food_event, food_event: { akbar_present: @food_event.akbar_present, amar_present: @food_event.amar_present, anthony_present: @food_event.anthony_present, name: @food_event.name }
    assert_redirected_to food_event_path(assigns(:food_event))
  end

  test "should destroy food_event" do
    assert_difference('FoodEvent.count', -1) do
      delete :destroy, id: @food_event
    end

    assert_redirected_to food_events_path
  end
end
