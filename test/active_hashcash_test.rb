require "test_helper"

class ActiveHashcashTest < Minitest::Test
  def test_stamp
    assert(true)
    assert(ActiveHashcash::Stamp.parse("1:20:220623:test::MPWRGuN3itbd1NiQ:00000000000003krh").valid?)
    refute(ActiveHashcash::Stamp.parse("1:20:220623:test::MPWRGuN3itbd1NiQ:00000000000003krh_").valid?)
  end

  class SampleController < ActionController::Base
    include ActiveHashcash
    attr_accessor :params

    def request
      OpenStruct.new(host: "test")
    end
  end

  def test_check_hashcash_when_spent_twice
    controller = SampleController.new
    controller.hashcash_store.clear
    controller.params = {hashcash: ActiveHashcash::Stamp.mint("test").to_s}
    refute(controller.check_hashcash)
    assert_raises(ActionController::InvalidAuthenticityToken) { controller.check_hashcash }
  end

  def test_check_hashcash_when_not_enough_bits
    controller = SampleController.new
    controller.hashcash_store.clear
    controller.params = {hashcash: ActiveHashcash::Stamp.mint("test", bits: 1).to_s}
    assert_raises(ActionController::InvalidAuthenticityToken) { controller.check_hashcash }
  end

  def test_check_hashcash_when_wrong_resource
    controller = SampleController.new
    controller.hashcash_store.clear
    controller.params = {hashcash: ActiveHashcash::Stamp.mint("wrong").to_s}
    assert_raises(ActionController::InvalidAuthenticityToken) { controller.check_hashcash }
  end

  def test_check_hashcash_when_expired
    controller = SampleController.new
    controller.hashcash_store.clear
    controller.params = {hashcash: ActiveHashcash::Stamp.mint("test", date: 2.days.ago.to_date).to_s}
    assert_raises(ActionController::InvalidAuthenticityToken) { controller.check_hashcash }
  end
end
