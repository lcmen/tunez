defmodule Tunez.Accounts.UserTest do
  use Tunez.DataCase, async: false

  alias Tunez.Accounts, warn: false

  describe "calculations" do
    test "user_email_length" do
      assert Accounts.user_email_length!("l@me.com") == 8
    end
  end

  describe "policies" do
    test "users can only read themselves" do
      [actor, other] = generate_many(user(), 2)

      assert Accounts.can_get_user_by_email?(actor, actor.email, data: actor)
      refute Accounts.can_get_user_by_email?(actor, other.email, data: other)
    end

    test "admins can read any user" do
      [user1, user2] = generate_many(user(), 2)
      actor = generate(user(role: :admin))

      assert Accounts.can_get_user_by_email?(actor, user1.email, data: user1)
      assert Accounts.can_get_user_by_email?(actor, user2.email, data: user2)
    end
  end
end
