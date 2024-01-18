# frozen_string_literal: true

RSpec.configure do |config|
  associations = %i[procedure patient hospital health_insurance]
  associations.each do |association|
    Bullet.add_safelist type: :unused_eager_loading, class_name: "EventProcedure", association: association
  end

  if Bullet.enable?
    config.before do
      Bullet.start_request
    end

    config.after do
      Bullet.perform_out_of_channel_notifications if Bullet.notification?
      Bullet.end_request
    end
  end
end
