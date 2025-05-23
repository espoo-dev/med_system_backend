# frozen_string_literal: true

require "administrate/base_dashboard"

class EventProcedureDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    date: Field::DateTime,
    health_insurance: Field::BelongsTo,
    hospital: Field::BelongsTo,
    patient: Field::BelongsTo,
    patient_service_number: Field::String,
    paid: Field::Boolean,
    procedure: Field::BelongsTo,
    room_type: Field::String,
    total_amount_cents: Field::Number,
    urgency: Field::Boolean,
    user: Field::BelongsTo,
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
    procedure
    user
    date
    paid
    total_amount_cents
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    date
    health_insurance
    hospital
    patient
    patient_service_number
    paid
    procedure
    room_type
    total_amount_cents
    urgency
    user
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    date
    health_insurance
    hospital
    patient
    patient_service_number
    paid
    procedure
    room_type
    total_amount_cents
    urgency
    user
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

  # Overwrite this method to customize how event procedures are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(event_procedure)
    "Event #ID: #{event_procedure.id}, #DATE: #{event_procedure.date.strftime('%d/%m/%Y')}"
  end
end
