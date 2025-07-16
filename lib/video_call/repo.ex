defmodule VideoCall.Repo do
  use Ecto.Repo,
    otp_app: :video_call,
    adapter: Ecto.Adapters.Postgres
end
