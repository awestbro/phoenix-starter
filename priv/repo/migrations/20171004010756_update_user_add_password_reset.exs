defmodule MyApp.Repo.Migrations.UpdateUserAddPasswordReset do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :password_reset_token, :uuid
      add :last_password_reset_attempt, :naive_datetime
    end
  end
end
