# spec helper settings.
# For more information take a look at Spec::Example::Configuration and Spec::Runner

ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require File.expand_path(File.dirname(__FILE__) + "/blueprints")
require 'spec'
require 'spec/rails'

Spec::Runner.configure do |config|
  # Active Record: remove if not using AR
  config.use_transactional_fixtures = true
  config.use_instantiated_fixtures  = false

  # reset our shams
  config.before(:each) { Sham.reset }

  # == Mock Framework
  config.mock_with :mocha
end

class ActiveRecord::Base
  def self.mock_saved(params = {})
    valid_columns = self.columns_hash.collect { |k,v| k }
    params = params.dup
    id = params.delete(:id)
    stubs = {}
    params.each do |attr_name, value|
      stubs[attr_name] = params.delete(attr_name) unless valid_columns.include?(attr_name)
    end
    instance = self.new(params)
    instance.stubs(:save).returns(true) unless stubs.has_key?(:save)
    instance.stubs(:new_record?).returns(stubs.delete(:new_record?) { |key| true })
    stubs.each do |meth, value|
      instance.stubs(meth).returns(value)
    end
    instance.stubs(:id).returns(id)
    instance.stubs(:to_param).returns(id.to_s)
    return instance
  end
end

class Class
  def publicize_methods
    saved_private_instance_methods = self.private_instance_methods
    saved_protected_instance_methods = self.protected_instance_methods
    self.class_eval do
      public *saved_private_instance_methods
      public *saved_protected_instance_methods
    end
    
    yield
    
    self.class_eval do
      private *saved_private_instance_methods
      protected *saved_protected_instance_methods
    end
  end
end

suppress LoadError do
  require 'ruby-debug'
end


# Taken from http://wincent.com/knowledge-base/Fixtures_considered_harmful%3F
class Hash
  # for excluding keys
  def except(*exclusions)
    self.reject { |key, value| exclusions.include? key.to_sym }
  end
 
  # for overriding keys
  def with(overrides = {})
    self.merge overrides
  end
end

