defmodule VideoCall.LearnReqSteps do
  @moduledoc false

  def make_request do
    # a step is an anonymous function that takes a request struct
    # and returns a request struct
    debug_url = fn request ->
      IO.inspect(URI.to_string(request.url))
      request
    end

    Req.new(url: "https://elixir-lang.org")
    |> Req.Request.append_request_steps(debug_url: debug_url)
    |> Req.get!()
  end
end
