defmodule VideoCall.LearnReqSteps do
  @moduledoc false

  def make_request do
    # a step is an anonymous function that takes a request struct
    # and returns a request struct
    debug_url = fn request ->
      IO.inspect(URI.to_string(request.url))
      request
    end

    # * Req is nothing but an HTTP client - CORS errors do not exist inside Req
    # * CORS applies when using the fetch API though as it implements it

    Req.new(url: "https://skeptic.bot/questions/bbebcf5e-c6a4-4b40-807d-ae1b797abaf8")
    |> Req.Request.append_request_steps(debug_url: debug_url)
    |> Req.get!()
  end

  def make_req_bin_request do
    req = Req.new(url: "https://reqbin.org/html")
    Req.get!(req)
  end
end
