defmodule MyApp.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias MyApp.Accounts.User


  schema "users" do
    field :username, :string
    field :email, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :password_hash, :string
    field :type, :string
    field :activation_token, Ecto.UUID
    field :activated, :boolean
    field :activation_attempts, :integer
    field :password_reset_token, Ecto.UUID
    field :last_password_reset_attempt, :naive_datetime

    timestamps()
  end

  def types, do: %{
    user: "user",
    user_paid: "user_paid",
    moderator: "moderator",
    admin: "admin",
  }

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:username, :email, :type, :activation_token, :activated, :activation_attempts, :password_reset_token, :last_password_reset_attempt])
    |> validate_required([:username, :email, :type])
    |> validate_inclusion(:type, Map.values(types()))
    |> validate_length(:username, min: 3, max: 30)
    |> validate_format(:email, ~r/([\w-\.]+)@((?:[\w]+\.)+)([a-zA-Z]{2,4})/, message: "Must have a valid email address")
    |> unique_constraint(:username)
    |> unique_constraint(:email)
  end

  def registration_changeset(model, params) do
    model
    |> cast(params, [:password, :password_confirmation])
    |> validate_required(:password)
    |> validate_required(:password_confirmation)
    |> cast(params, [:password, :password_confirmation])
    |> validate_length(:password, min: 4)
    |> validate_confirmation(:password)
    |> put_pass_hash()
  end

  def change_password_changeset(model, params) do
    model
    |> registration_changeset(params)
  end

  def put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end
end
