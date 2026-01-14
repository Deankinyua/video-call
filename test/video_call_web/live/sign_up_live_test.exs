defmodule VideoCallWeb.UserRegistrationLiveTest do
  use VideoCallWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import VideoCall.AccountsFixtures

  describe "/sign-up" do
    test "renders registration page", %{conn: conn} do
      {:ok, _live, html} = live(conn, ~p"/sign-up")

      assert html =~ "Register"
      assert html =~ "Log in"
      assert html =~ "Create an account"
    end

    test "redirects if already logged in", %{conn: conn} do
      result =
        conn
        |> sign_in_user(user_fixture())
        |> live(~p"/sign-up")
        |> follow_redirect(conn, "/")

      assert {:ok, _conn} = result
    end

    test "renders errors for invalid data", %{conn: conn} do
      {:ok, live, _html} = live(conn, ~p"/sign-up")

      result =
        live
        |> element("#registration_form")
        |> render_change(user: %{"email" => "with spaces", "password" => "trt"})

      assert result =~ "must have the @ sign and no spaces"
      assert result =~ "should be at least 5 character"
    end

    test "creates account and logs the user in", %{conn: conn} do
      {:ok, live, _html} = live(conn, ~p"/sign-up")

      email = unique_user_email()
      username = unique_username()

      form =
        form(live, "#registration_form",
          user: %{
            email: email,
            password: "deankinyuakenya",
            username: username
          }
        )

      render_submit(form)

      conn = follow_trigger_action(form, conn)

      assert redirected_to(conn) == ~p"/"

      conn_2 = get(conn, "/")
      _response = html_response(conn_2, 200)
    end

    test "renders errors for duplicated email", %{conn: conn} do
      {:ok, live, _html} = live(conn, ~p"/sign-up")

      user = user_fixture(%{email: "test@email.com"})

      result =
        live
        |> form("#registration_form",
          user: %{"email" => user.email, "password" => "valid_password"}
        )
        |> render_submit()

      assert result =~ "has already been taken"
    end
  end
end
