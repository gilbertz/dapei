# encoding: utf-8

class TestJob
  include Sidekiq::Worker
  def perform
    p 'test message ok'
  end
end