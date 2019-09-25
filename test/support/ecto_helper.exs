Logger.configure(level: :info)
alias OneTimePassEcto.TestRepo

Application.put_env(
  :one_time_pass_ecto,
  :pg_test_url,
  "ecto://" <> (System.get_env("PG_URL") || "postgres:postgres@localhost")
)

Application.put_env(
  :one_time_pass_ecto,
  TestRepo,
  adapter: Ecto.Adapters.Postgres,
  url: Application.get_env(:one_time_pass_ecto, :pg_test_url) <> "/one_time_pass_ecto_test",
  pool: Ecto.Adapters.SQL.Sandbox
)

defmodule OneTimePassEcto.TestRepo do
  use Ecto.Repo,
        otp_app: :one_time_pass_ecto,
        adapter: Ecto.Adapters.Postgres

end

defmodule UsersMigration do
  use Ecto.Migration

  def change do
    create table(:users) do
      add(:email, :string)
      add(:otp_required, :boolean)
      add(:otp_secret, :string)
      add(:otp_last, :integer)
      add(:second_otp_secret, :string)
      add(:second_otp_last, :integer)
    end

    create(unique_index(:users, [:email]))
  end
end

defmodule OneTimePassEcto.TestUser do
  use Ecto.Schema

  schema "users" do
    field(:email, :string)
    field(:otp_required, :boolean)
    field(:otp_secret, :string)
    field(:otp_last, :integer)
    field(:second_otp_secret, :string)
    field(:second_otp_last, :integer)
  end
end

defmodule OneTimePassEcto.TestCase do
  use ExUnit.CaseTemplate

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(TestRepo)
  end
end

{:ok, _} = Ecto.Adapters.Postgres.ensure_all_started(TestRepo, :temporary)

_ = Ecto.Adapters.Postgres.storage_down(TestRepo.config())
:ok = Ecto.Adapters.Postgres.storage_up(TestRepo.config())

{:ok, _pid} = TestRepo.start_link()

:ok = Ecto.Migrator.up(TestRepo, 0, UsersMigration, log: false)
Ecto.Adapters.SQL.Sandbox.mode(TestRepo, :manual)
