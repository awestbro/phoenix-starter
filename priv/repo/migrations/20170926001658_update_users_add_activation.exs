defmodule MyApp.Repo.Migrations.UpdateUsersAddActivation do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :activation_token, :uuid
      add :activated, :boolean, default: false, null: false
    end
  end
end
