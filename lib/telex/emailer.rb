require 'erubis'
require 'redcarpet'
require 'mail'

class Telex::Emailer
  HTML_TEMPLATE = File.read(File.expand_path('../../templates/email.html.erb', __FILE__))

  def initialize(email:, message_id: nil, in_reply_to: nil, subject:, body:)
    self.email = email
    self.message_id = message_id
    self.in_reply_to = in_reply_to
    self.subject = subject
    self.body = body
  end

  def deliver!
    mail = Mail.new
    mail.to         = email
    mail.from       = 'Heroku Notifications <bot@heroku.com>'
    if message_id
      mail.message_id = "<#{message_id}@notifications.heroku.com>"
    elsif in_reply_to
      mail.in_reply_to = "<#{in_reply_to}@notifications.heroku.com>"
    end
    mail.subject    = subject

    text_part = Mail::Part.new
    text_part.body = body
    mail.text_part = text_part

    html_part = Mail::Part.new
    html_part.content_type = 'text/html; charset=UTF-8'
    html_part.body = generate_html
    mail.html_part = html_part

    mail.deliver!
    Telex::Sample.count "emails"
  end

  private
  attr_accessor :email, :message_id, :subject, :body, :in_reply_to

  def generate_html
    markdown = Redcarpet::Markdown.new(
      Redcarpet::Render::HTML.new(filter_html: true),
      no_intra_emphasis: true,
      autolink: true
    )
    rendered_body = markdown.render(body)
    Erubis::Eruby.new(HTML_TEMPLATE).result(body: rendered_body)
  end
end
