defmodule OneTimePassEctoTest do
  use OneTimePassEcto.TestCase

  import Ecto.Changeset
  alias OneTimePassEcto.{TestRepo, TestUser, UserHelper}

  setup context do
    %{id: user_id} = UserHelper.add_user()
    otp_last = context[:last] || 0
    update_repo(user_id, otp_last)
    {:ok, %{user_id: user_id}}
  end

  def login(params, opts) do
    OneTimePassEcto.verify(params, TestRepo, TestUser, opts)
  end

  def update_repo(user_id, otp_last) do
    TestRepo.get(TestUser, user_id)
    |> change(%{otp_last: otp_last})
    |> TestRepo.update!
  end

  test "check hotp with default options", %{user_id: user_id} do
    user = %{"hotp" => "816065", "id" => user_id}
    {:ok, %{id: id, otp_last: otp_last}} = login(user, [])
    assert id == user_id
    assert otp_last == 2
    fail = %{"hotp" => "816066", "id" => user_id}
    {:error, message} = login(fail, [])
    assert message
  end

  @tag last: 18
  test "check hotp with updated last", %{user_id: user_id} do
    user = %{"hotp" => "088239", "id" => user_id}
    {:ok, %{id: id, otp_last: otp_last}} = login(user, [])
    assert id == user_id
    assert otp_last == 19
    fail = %{"hotp" => "088238", "id" => user_id}
    {:error, message} = login(fail, [])
    assert message
  end

  test "check totp with default options", %{user_id: user_id} do
    token = OneTimePassEcto.Base.gen_totp("MFRGGZDFMZTWQ2LK")
    user = %{"totp" => token, "id" => user_id}
    {:ok, user} = login(user, [])
    assert user
  end

  test "disallow totp check with same token", %{user_id: user_id} do
    token = OneTimePassEcto.Base.gen_totp("MFRGGZDFMZTWQ2LK")
    user = %{"totp" => token, "id" => user_id}
    {:ok, %{otp_last: otp_last}} = login(user, [])
    update_repo(user_id, otp_last)
    {:error, message} = login(user, [])
    assert message
  end

  test "disallow totp check with earlier token that is still valid", %{user_id: user_id} do
    token = OneTimePassEcto.Base.gen_totp("MFRGGZDFMZTWQ2LK")
    user = %{"totp" => token, "id" => user_id}
    {:ok, %{otp_last: otp_last}} = login(user, [])
    update_repo(user_id, otp_last)
    new_token = OneTimePassEcto.Base.gen_hotp("MFRGGZDFMZTWQ2LK", otp_last - 1)
    user = %{"totp" => new_token, "id" => user_id}
    {:error, message} = login(user, [])
    assert message
  end

end
