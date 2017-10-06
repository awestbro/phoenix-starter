defmodule MyApp.Repo.Migrations.UpdateUsersAddActivationAttempts do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :activation_attempts, :integer, default: 0, null: false
    end
  end
end
