defmodule HubIdentityWeb.Authentication.AccessCookiesServerTest do
  use HubIdentityWeb.ConnCase, async: false

  import HubIdentity.Factory

  alias HubCluster.MementoRepo
  alias HubIdentityWeb.Authentication.{AccessCookie, AccessCookiesServer}

  setup do
    MementoRepo.clear(AccessCookie)
    :ok
  end

  describe "create_cookie/1" do
    test "with a User creates a cookie and returns the cookie id" do
      user = insert(:user)
      {:ok, cookie} = AccessCookiesServer.create_cookie(user)
      user_cookie = MementoRepo.get_one(AccessCookie, cookie.id)
      assert user_cookie.owner.uid == user.uid
      assert user_cookie.expires_at != nil
    end

    test "with anything other than User returns error" do
      client_service = insert(:client_service)
      assert {:error, :unknown_cookie_type} == AccessCookiesServer.create_cookie(client_service)
    end
  end

  describe "delete_cookies/1" do
    test "with a users uid deletes all that users cookies" do
      cookie_user = insert(:user)

      for _ <- 1..5 do
        user = insert(:user)
        AccessCookiesServer.create_cookie(user)
      end

      assert {:ok, _cookie} = AccessCookiesServer.create_cookie(cookie_user)
      assert {:ok, _cookie} = AccessCookiesServer.create_cookie(cookie_user)

      cookies = AccessCookiesServer.get_cookies(%{uid: cookie_user.uid})
      assert length(cookies) == 2

      assert :ok = AccessCookiesServer.delete_cookies(%{uid: cookie_user.uid})

      assert [] == AccessCookiesServer.get_cookies(%{uid: cookie_user.uid})

      assert length(AccessCookiesServer.list_cookies()) == 5
    end

    test "A user with no cookies does not delete other users cookies" do
      for _ <- 1..5 do
        user = insert(:user)
        AccessCookiesServer.create_cookie(user)
      end

      no_cookie_user = insert(:user)

      assert length(AccessCookiesServer.list_cookies()) == 5
      assert :ok = AccessCookiesServer.delete_cookies(%{uid: no_cookie_user.uid})
      assert length(AccessCookiesServer.list_cookies()) == 5
    end
  end

  describe "get_cookie/1" do
    test "with a valid id returns the cookie" do
      user = insert(:user)
      {:ok, cookie} = AccessCookiesServer.create_cookie(user)

      user_cookie = AccessCookiesServer.get_cookie(cookie.id)
      assert user_cookie.owner.uid == user.uid
    end

    test "with invalid id returns nil" do
      assert nil == AccessCookiesServer.get_cookie("not_a_cookie")
    end
  end

  describe "list_cookies/0" do
    test "returns all cookies stored" do
      for _ <- 1..3 do
        user = insert(:user)
        AccessCookiesServer.create_cookie(user)
      end

      cookies = AccessCookiesServer.list_cookies()
      assert 3 == length(cookies)
    end
  end

  describe "withdraw_cookie/1" do
    test "with valid id deletes and returns the cookie" do
      user = insert(:user)
      {:ok, cookie} = AccessCookiesServer.create_cookie(user)

      {:ok, user_cookie} = AccessCookiesServer.withdraw_cookie(cookie.id)
      assert user_cookie.owner.uid == user.uid
      assert nil == AccessCookiesServer.get_cookie(cookie.id)
    end
  end

  describe "get_cookies/1" do
    test "with a owner uid gets all the cookies" do
      cookie_user = insert(:user)

      for _ <- 1..5 do
        user = insert(:user)
        AccessCookiesServer.create_cookie(user)
      end

      assert {:ok, cookie_1} = AccessCookiesServer.create_cookie(cookie_user)
      assert {:ok, cookie_2} = AccessCookiesServer.create_cookie(cookie_user)

      assert length(AccessCookiesServer.list_cookies()) == 7

      cookies = AccessCookiesServer.get_cookies(%{uid: cookie_user.uid})
      assert length(cookies) == 2
      assert Enum.any?(cookies, fn cookie -> cookie.id == cookie_1.id end)
      assert Enum.any?(cookies, fn cookie -> cookie.id == cookie_2.id end)
    end

    test "with no cookies returns empty list" do
      for _ <- 1..5 do
        user = insert(:user)
        AccessCookiesServer.create_cookie(user)
      end

      no_cookie_user = insert(:user)

      assert [] == AccessCookiesServer.get_cookies(%{uid: no_cookie_user.uid})
    end
  end
end
