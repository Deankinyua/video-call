defmodule VideoCall.TextSearchHelpers do
  @moduledoc """
  Contains helper functions for performing full text search across contexts
  """

  import Ecto.Query

  @type dynamic_expression :: %Ecto.Query.DynamicExpr{}
  @type query :: Ecto.Query.t()
  @type search_query :: String.t()

  @spec apply_search_ordering(query(), search_query()) :: query()
  def apply_search_ordering(query, search_query)
      when is_binary(search_query) and search_query != "" do
    order_by(
      query,
      [user: user],
      desc:
        fragment(
          "ts_rank(?, websearch_to_tsquery('english', ?))",
          user.search_vector,
          ^search_query
        )
    )
  end

  def apply_search_ordering(query, _no_search) do
    order_by(query, [u], {:desc, u.inserted_at})
  end

  @spec apply_filter({:search, search_query()}, dynamic_expression()) :: dynamic_expression()
  def apply_filter({:search, search_query}, dynamic)
      when is_binary(search_query) and search_query != "" do
    # Use PostgreSQL websearch_to_tsquery for better search experience
    # websearch_to_tsquery handles phrases, AND/OR operators naturally

    formatted_query =
      search_query
      |> String.split()
      |> Enum.map_join(" & ", &"#{&1}:*")

    dynamic(
      [user: user],
      ^dynamic and
        fragment("? @@ to_tsquery('english', ?)", user.search_vector, ^formatted_query)
    )
  end

  def apply_filter({:search, _search_query}, dynamic), do: dynamic
end
