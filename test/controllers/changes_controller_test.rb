require 'test_helper'

class ChangesControllerTest < ActionController::TestCase
  setup do
    @change = changes(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:changes)
  end

  test "should create change" do
    assert_difference('Change.count') do
      post :create, change: {  }
    end

    assert_response 201
  end

  test "should show change" do
    get :show, id: @change
    assert_response :success
  end

  test "should update change" do
    put :update, id: @change, change: {  }
    assert_response 204
  end

  test "should destroy change" do
    assert_difference('Change.count', -1) do
      delete :destroy, id: @change
    end

    assert_response 204
  end
end
