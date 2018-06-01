require 'test_helper'

class ChunksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @chunk = chunks(:one)
  end

  test "should get index" do
    get chunks_url
    assert_response :success
  end

  test "should get new" do
    get new_chunk_url
    assert_response :success
  end

  test "should create chunk" do
    assert_difference('Chunk.count') do
      post chunks_url, params: { chunk: { chunk_content: @chunk.chunk_content, chunk_type: @chunk.chunk_type, confidence: @chunk.confidence, vid_id: @chunk.vid_id } }
    end

    assert_redirected_to chunk_url(Chunk.last)
  end

  test "should show chunk" do
    get chunk_url(@chunk)
    assert_response :success
  end

  test "should get edit" do
    get edit_chunk_url(@chunk)
    assert_response :success
  end

  test "should update chunk" do
    patch chunk_url(@chunk), params: { chunk: { chunk_content: @chunk.chunk_content, chunk_type: @chunk.chunk_type, confidence: @chunk.confidence, vid_id: @chunk.vid_id } }
    assert_redirected_to chunk_url(@chunk)
  end

  test "should destroy chunk" do
    assert_difference('Chunk.count', -1) do
      delete chunk_url(@chunk)
    end

    assert_redirected_to chunks_url
  end
end
