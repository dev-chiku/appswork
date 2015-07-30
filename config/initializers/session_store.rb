# Be sure to restart your server when you modify this file.

#Rails.application.config.session_store :cookie_store, key: '_appswork_session'
Rails.application.config.session_store :active_record_store, key: '_appswork_session', :expire_after => 30.days
# , :expire_after => 1.months
