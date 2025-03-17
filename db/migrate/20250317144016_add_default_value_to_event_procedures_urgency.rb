class AddDefaultValueToEventProceduresUrgency < ActiveRecord::Migration[7.1]
  def change
    change_column_default :event_procedures, :urgency, from: nil, to: false
  end
end
