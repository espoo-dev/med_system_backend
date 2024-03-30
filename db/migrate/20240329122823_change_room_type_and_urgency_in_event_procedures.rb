# frozen_string_literal: true

class ChangeRoomTypeAndUrgencyInEventProcedures < ActiveRecord::Migration[7.0]
  def change
    change_column_null :event_procedures, :room_type, true
    change_column_null :event_procedures, :urgency, true
    change_column_default :event_procedures, :urgency, from: false, to: nil
  end
end
