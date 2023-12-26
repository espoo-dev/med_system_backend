# frozen_string_literal: true

class OperationGenerator < Rails::Generators::NamedBase
  source_root File.expand_path("templates", __dir__)

  def generate
    template "operation.erb", File.join("app/operations", class_path, "#{file_name}.rb")
    template "spec.erb", File.join("spec/operations", class_path, "#{file_name}_spec.rb")
  end
end
