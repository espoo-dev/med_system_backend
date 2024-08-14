# frozen_string_literal: true

require "administrate/base_dashboard"

class MedicalShiftDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    amount_cents: Field::Number,
    start_date: Field::Date,
    start_hour: Field::Time,
    hospital_name: Field::String,
    user: Field::BelongsTo,
    payd: Field::Boolean,
    shift: Field::String,
    title: Field::String,
    workload: Field::String,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    id
    amount_cents
    start_date
    start_hour
    shift
    hospital_name
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    amount_cents
    start_date
    start_hour
    hospital_name
    user
    payd
    shift
    workload
    title
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    amount_cents
    start_date
    start_hour
    hospital_name
    user
    payd
    workload
  ].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { resources.where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how medical shifts are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(medical_shift)
  #   "MedicalShift ##{medical_shift.id}"
  # end
end
