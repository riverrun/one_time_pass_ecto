defmodule OneTimePassEcto.UserHelper do
  import Ecto.Changeset
  alias OneTimePassEcto.{TestRepo, TestUser}

  @attrs %{
    email: "brian@mail.com",
    otp_required: true,
    otp_secret: "MFRGGZDFMZTWQ2LK",
    otp_last: 0,
    second_otp_secret: "E4IX6ABMKZX7GN56",
    second_otp_last: 0
  }

  def add_user(attrs \\ @attrs) do
    %TestUser{}
    |> user_changeset(attrs)
    |> TestRepo.insert!()
  end

  defp user_changeset(user, params) do
    user
    |> cast(params, Map.keys(params))
    |> validate_required([:email])
    |> unique_constraint(:email)
  end
end
