defmodule OneTimePassEcto.BaseTest do
  use ExUnit.Case

  alias OneTimePassEcto.Base

  def get_count do
    trunc(System.system_time(:second) / 30)
  end

  test "generate secret with correct input" do
    assert Base.gen_secret() |> byte_size == 16
    assert Base.gen_secret(16) |> byte_size == 16
    assert Base.gen_secret(26) |> byte_size == 26
    assert Base.gen_secret(32) |> byte_size == 32
    assert Base.gen_secret(64) |> byte_size == 64
  end

  test "error when generating secret with the wrong length" do
    for i <- [12, 24, 36] do
      assert_raise ArgumentError, "Invalid length", fn ->
        Base.gen_secret(i)
      end
    end
  end

  test "valid otp token" do
    refute Base.valid_token("12345", 5)
    assert Base.valid_token("123456", 6)
    refute Base.valid_token("123456", 8)
    assert Base.valid_token("12345678", 8)
  end

  test "generate hotp" do
    assert Base.gen_hotp("MFRGGZDFMZTWQ2LK", 1) == "765705"
    assert Base.gen_hotp("MFRGGZDFMZTWQ2LK", 2) == "816065"
    assert Base.gen_hotp("GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ", 5) == "254676"
    assert Base.gen_hotp("GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ", 8) == "399871"
  end

  test "generate hotp with zero padding" do
    assert Base.gen_hotp("MFRGGZDFMZTWQ2LK", 19) == "088239"
  end

  test "check hotp" do
    assert Base.check_hotp("816065", "MFRGGZDFMZTWQ2LK") == 2
    assert Base.check_hotp("088239", "MFRGGZDFMZTWQ2LK", last: 18) == 19
    assert Base.check_hotp("287922", "GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ", last: 5) == 6
  end

  test "check hotp fails for outside window" do
    refute Base.check_hotp("088239", "MFRGGZDFMZTWQ2LK", last: 10)
    refute Base.check_hotp("287922", "GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ", last: 4, window: 0)
    refute Base.check_hotp("287922", "GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ", last: 3, window: 1)
  end

  test "check totp" do
    assert Base.gen_totp("MFRGGZDFMZTWQ2LK") |> Base.check_totp("MFRGGZDFMZTWQ2LK")

    assert Base.gen_totp("GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ")
           |> Base.check_totp("GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ")
  end

  test "check totp fails for outside window" do
    token = Base.gen_hotp("MFRGGZDFMZTWQ2LK", get_count() - 2)
    refute Base.check_totp(token, "MFRGGZDFMZTWQ2LK")
    token = Base.gen_hotp("GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ", get_count() + 2)
    refute Base.check_totp(token, "GEZDGNBVGY3TQOJQGEZDGNBVGY3TQOJQ")
  end
end
