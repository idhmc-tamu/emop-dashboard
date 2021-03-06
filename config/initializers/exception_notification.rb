if Rails.env.to_s != 'development'
  EmopDashboard::Application.config.middleware.use ExceptionNotification::Rack,
    :ignore_crawlers => %w{Googlebot bingbot EasouSpider scan},
    :email => {
      :email_prefix => Rails.application.secrets.exception_notifier['email_prefix'],
      :sender_address => Rails.application.secrets.exception_notifier['sender_address'],
      :exception_recipients => Rails.application.secrets.exception_notifier['exception_recipients']
    }
end
