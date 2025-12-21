defmodule VideoCallWeb.UserSessionController do
  @moduledoc false

  use VideoCallWeb, :controller

  alias VideoCall.Accounts
  alias VideoCallWeb.UserAuth

  @type conn :: Plug.Conn.t()
  @type params :: map()

  @spec create(conn(), params()) :: conn()
  def create(conn, %{"_action" => "registered"} = params),
    do: create(conn, params, "Account created successfully!")

  def create(conn, params), do: create(conn, params, "Welcome back!")

  defp create(conn, %{"user" => %{"email" => email, "password" => password} = user_params}, info) do
    user = Accounts.get_user_by_email_and_password(email, password)

    if user do
      conn
      |> put_flash(:info, info)
      |> UserAuth.log_in_user(user, user_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      conn
      |> put_flash(:email, email)
      |> put_flash(:error, "Invalid email or password")
      |> redirect(to: ~p"/sign-in")
    end
  end

  @spec delete(conn(), params()) :: conn()
  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> UserAuth.log_out_user()
  end
end
