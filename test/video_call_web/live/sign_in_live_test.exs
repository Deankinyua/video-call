defmodule VideoCallWeb.UserLoginLiveTest do
  use VideoCallWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import VideoCall.AccountsFixtures

  describe "/sign-in" do
    test "renders log in page", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/sign-in")

      assert html =~ "Log in"
      assert html =~ "Sign up"
    end

    test "redirects if user is already logged in", %{conn: conn} do
      result =
        conn
        |> sign_in_user(user_fixture())
        |> live(~p"/sign-in")
        |> follow_redirect(conn, "/")

      assert {:ok, _conn} = result
    end

    test "redirects if user logs in with valid credentials", %{conn: conn} do
      password = "deankinyuakenya"
      user = user_fixture(%{password: password})

      {:ok, live, _html} = live(conn, ~p"/sign-in")

      form =
        form(live, "#login_form",
          user: %{
            email: user.email,
            password: password
          }
        )

      conn = submit_form(form, conn)

      assert redirected_to(conn) == ~p"/"
    end

    test "redirects to login page with a flash error if there are no valid credentials", %{
      conn: conn
    } do
      {:ok, live, _html} = live(conn, ~p"/sign-in")

      form =
        form(live, "#login_form",
          user: %{email: "test@email.com", password: "noon", remember_me: true}
        )

      conn = submit_form(form, conn)

      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Invalid email or password"

      assert redirected_to(conn) == "/sign-in"
    end
  end
end
