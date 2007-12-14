require 'haml/engine'
require 'rubygems'
require 'active_support'
require 'action_view'

module Haml
  class Template
    class << self
      @@options = {}

      # Gets various options for Haml. See README for details.
      def options
        @@options
      end

      # Sets various options for Haml. See README for details.
      def options=(value)
        @@options = value
      end
    end
  end
end

# This module refers to the ActionView module that's part of Ruby on Rails.
# Haml can be used as an alternate templating engine for it,
# and includes several modifications to make it more Haml-friendly.
# The documentation can be found
# here[http://rubyonrails.org/api/classes/ActionView/Base.html].
module ActionView
  class Base # :nodoc:
    def delegate_template_exists_with_haml(template_path)
      template_exists?(template_path, :haml) && [:haml]
    end
    alias_method :delegate_template_exists_without_haml, :delegate_template_exists?
    alias_method :delegate_template_exists?, :delegate_template_exists_with_haml

    def compile_template_with_haml(extension, template, file_name, local_assigns)
      return compile_haml(template, file_name, local_assigns) if extension.to_s == "haml"
      compile_template_without_haml(extension, template, file_name, local_assigns)
    end
    alias_method :compile_template_without_haml, :compile_template
    alias_method :compile_template, :compile_template_with_haml

    def compile_haml(template, file_name, local_assigns)
      render_symbol = assign_method_name(:haml, template, file_name)
      locals = local_assigns.keys
      
      @@template_args[render_symbol] ||= {}
      locals_keys = @@template_args[render_symbol].keys | locals
      @@template_args[render_symbol] = locals_keys.inject({}) { |h, k| h[k] = true; h }

      options = Haml::Template.options.dup
      options[:filename] = file_name || 'compiled-template'

      begin
        Haml::Engine.new(template, options).def_method(CompiledTemplates, render_symbol, *locals)
      rescue Exception => e
        if logger
          logger.debug "ERROR: compiling #{render_symbol} RAISED #{e}"
          logger.debug "Backtrace: #{e.backtrace.join("\n")}"
        end

        raise TemplateError.new(@base_path, file_name || template, @assigns, template, e)
      end

      @@compile_time[render_symbol] = Time.now
    end
  end
end