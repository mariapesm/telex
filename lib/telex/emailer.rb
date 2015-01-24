require 'erubis'
require 'redcarpet'
require 'mail'

class Telex::Emailer
  HTML_TEMPLATE = File.read(File.expand_path('../../templates/email.html.erb', __FILE__))

  def initialize(email:, notification_id: nil, in_reply_to: nil, subject:, body:, action: nil)
    self.email = email
    self.notification_id = notification_id
    self.in_reply_to = in_reply_to
    self.subject = subject
    self.body = body
    self.action = action
  end

  def deliver!
    mail = Mail.new
    mail.to      = email
    mail.from    = 'Heroku Notifications <bot@heroku.com>'
    mail.subject = subject
    if notification_id
      mail.message_id = "<#{notification_id}@notifications.heroku.com>"
    elsif in_reply_to
      mail.in_reply_to = "<#{in_reply_to}@notifications.heroku.com>"
    end

    text_part = Mail::Part.new
    text_part.body = body
    mail.text_part = text_part

    html_part = Mail::Part.new
    html_part.content_type = 'text/html; charset=UTF-8'
    html_part.body = generate_html
    mail.html_part = html_part

    mail.deliver!
    Telex::Sample.count "emails"
    mail
  end

  private
  attr_accessor :email, :notification_id, :subject, :body, :in_reply_to, :action

  def generate_html
    markdown = Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(filter_html: true),
      no_intra_emphasis: true,
      autolink: true
    )
    rendered_body = markdown.render(body)

    Erubis::Eruby.new(HTML_TEMPLATE).result(
      body: rendered_body,
      png_url: png_url,
      email_action_ld: email_action_ld)
  end

  def png_url
    id = notification_id || in_reply_to
    return nil unless id

    if Config.deployment == 'production'
      "https://telex.heroku.com/user/notifications/#{id}/read.png"
    elsif Config.deployment == 'staging'
      "https://telex-staging.herokuapp.com/user/notifications/#{id}/read.png"
    end
  end

  def email_action_ld
    return unless action
    {
      "@context" => "http://schema.org",
      "@type" => "EmailMessage",
      "action" => {
        "@type" => "ViewAction",
        "url" => action[:url],
        "name" => action[:label]
      }
    }
  end
end
