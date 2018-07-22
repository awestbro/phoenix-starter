defmodule MyAppWeb.Guardian do
  use Guardian, otp_app: :myapp
  alias MyApp.Accounts.User
  alias MyApp.Repo

  def subject_for_token(%User{} = user, _claims) do
    {:ok, "User:#{user.id}"}
  end

  def subject_for_token(_, _) do
    {:error, "Unknown resource type"}
  end

  def resource_from_claims(%{"sub" => "User:" <> id}) do
    {:ok, Repo.get(User, id)}
  end
  def resource_from_claims(_claims) do
    {:error, "Unknown resource type"}
  end
end
