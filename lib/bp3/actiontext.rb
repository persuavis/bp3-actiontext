# frozen_string_literal: true

require 'active_support/core_ext/module/attribute_accessors'
require 'active_support/inflector'

require_relative 'actiontext/railtie'
require_relative 'actiontext/version'

module Bp3
  module Actiontext
    mattr_accessor :site_class_name, :tenant_class_name, :workspace_class_name

    def self.site_class
      @@site_class ||= site_class_name.constantize # rubocop:disable Style/ClassVars
    end

    def self.tenant_class
      @@tenant_class ||= tenant_class_name.constantize # rubocop:disable Style/ClassVars
    end

    def self.workspace_class
      @@workspace_class ||= workspace_class_name.constantize # rubocop:disable Style/ClassVars
    end
  end
end
