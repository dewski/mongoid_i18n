require 'mongoid/i18n/localized_field'
require 'mongoid/i18n/criterion/selector'

module Mongoid
  module I18n
    extend ActiveSupport::Concern

    module ClassMethods
      def localized_field(name, options = {})
        field name, options.merge(:type => LocalizedField)
      end

      protected
      def create_accessors(name, meth, options = {})
        if options[:type] == LocalizedField
          if options[:use_default_if_empty]
            define_method(meth) { read_attribute(name)[::I18n.locale.to_s] || read_attribute(name)[::I18n.default_locale.to_s] rescue ''}
          else
            define_method(meth) { read_attribute(name)[::I18n.locale.to_s] rescue '' }
          end
          define_method("#{meth}=") do |value|
            value = if value.is_a?(Hash)
              (@attributes[name] || {}).merge(value)
            else
              (@attributes[name] || {}).merge(::I18n.locale.to_s => value)
            end
            value.delete_if { |key, value| value.blank? } if options[:clear_empty_values]
            write_attribute(name, value)
          end
          define_method("#{meth}_translations") { read_attribute(name) }
          if options[:clear_empty_values]
            define_method("#{meth}_translations=") { |value| write_attribute(name, value.delete_if { |key, value| value.blank? }) }
          else
            define_method("#{meth}_translations=") { |value| write_attribute(name, value) }
          end
        else
          super
        end
      end
    end
  end
end