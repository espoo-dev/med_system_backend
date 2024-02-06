# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2024_02_06_181632) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "devise_api_tokens", force: :cascade do |t|
    t.string "resource_owner_type", null: false
    t.bigint "resource_owner_id", null: false
    t.string "access_token", null: false
    t.string "refresh_token"
    t.integer "expires_in", null: false
    t.datetime "revoked_at"
    t.string "previous_refresh_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["access_token"], name: "index_devise_api_tokens_on_access_token"
    t.index ["previous_refresh_token"], name: "index_devise_api_tokens_on_previous_refresh_token"
    t.index ["refresh_token"], name: "index_devise_api_tokens_on_refresh_token"
    t.index ["resource_owner_type", "resource_owner_id"], name: "index_devise_api_tokens_on_resource_owner"
  end

  create_table "event_procedures", force: :cascade do |t|
    t.bigint "procedure_id", null: false
    t.bigint "patient_id", null: false
    t.bigint "hospital_id", null: false
    t.bigint "health_insurance_id", null: false
    t.string "patient_service_number", null: false
    t.datetime "date", null: false
    t.boolean "urgency", default: false, null: false
    t.datetime "payd_at"
    t.string "room_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "total_amount_cents"
    t.bigint "user_id", null: false
    t.index ["health_insurance_id"], name: "index_event_procedures_on_health_insurance_id"
    t.index ["hospital_id"], name: "index_event_procedures_on_hospital_id"
    t.index ["patient_id"], name: "index_event_procedures_on_patient_id"
    t.index ["procedure_id"], name: "index_event_procedures_on_procedure_id"
    t.index ["user_id"], name: "index_event_procedures_on_user_id"
  end

  create_table "health_insurances", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hospitals", force: :cascade do |t|
    t.string "name", null: false
    t.string "address", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["address"], name: "index_hospitals_on_address", unique: true
    t.index ["name"], name: "index_hospitals_on_name", unique: true
  end

  create_table "medical_shifts", force: :cascade do |t|
    t.bigint "hospital_id", null: false
    t.string "workload", null: false
    t.datetime "date", null: false
    t.integer "amount_cents", default: 0, null: false
    t.boolean "was_paid", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["date"], name: "index_medical_shifts_on_date"
    t.index ["hospital_id"], name: "index_medical_shifts_on_hospital_id"
    t.index ["user_id"], name: "index_medical_shifts_on_user_id"
    t.index ["was_paid"], name: "index_medical_shifts_on_was_paid"
  end

  create_table "patients", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "procedures", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "amount_cents", default: 0, null: false
    t.text "description"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "oauth_provider"
    t.string "oauth_uid"
    t.boolean "admin", default: false, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "event_procedures", "health_insurances"
  add_foreign_key "event_procedures", "hospitals"
  add_foreign_key "event_procedures", "patients"
  add_foreign_key "event_procedures", "procedures"
  add_foreign_key "event_procedures", "users"
  add_foreign_key "medical_shifts", "hospitals"
  add_foreign_key "medical_shifts", "users"
end
