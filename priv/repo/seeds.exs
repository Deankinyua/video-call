# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     VideoCall.Repo.insert!(%VideoCall.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias VideoCall.Accounts

attrs = %{
  email: "kinyuadean@gmail.com",
  username: "Dean",
  password: "deandeandean"
}

Accounts.register_user(attrs)
