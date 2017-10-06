defmodule MyApp.Email do
  import Bamboo.Email

  # Usage: MyApp.Email.welcome_email(conn, user) |> MyApp.Mailer.deliver_now
  def activation_email(conn, user) do
    activation_link = MyAppWeb.Router.Helpers.url(conn) <> MyAppWeb.Router.Helpers.account_path(conn, :activate, user.id, user.activation_token)
    base_email()
    |> to(user.email)
    |> subject("MyApp - Activate your account!")
    |> html_body("""
      <div>
        <div>Welcome to MyApp!</div>
        <div><a href="#{activation_link}" target="__blank">Activate your email!</a></div>
      </div>
    """)
    |> text_body("Welcome to MyApp! Activation link: #{activation_link}")
  end

  def reset_password_email(conn, user) do
    reset_link = MyAppWeb.Router.Helpers.url(conn) <> MyAppWeb.Router.Helpers.account_path(conn, :show_password_change, user.id, user.password_reset_token)
    base_email()
    |> to(user.email)
    |> subject("MyApp - Password reset")
    |> html_body("""
      <div>
        <div>Here's a link to reset your MyApp password!</div>
        <div><a href="#{reset_link}" target="__blank">Reset your password</a></div>
      </div>
    """)
    |> text_body("MyApp password reset link: #{reset_link}")
  end

  defp base_email do
    new_email()
    |> from("support@myapp.com")
    |> put_header("Reply-To", "support@myapp.com")
  end
end
