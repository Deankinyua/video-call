.PHONY: iex_server ci

.DEFAULT_GOAL := iex_server

iex_server:
	iex -S mix phx.server
	
ci:
	MIX_ENV=test mix compile
	mix ci
	MIX_ENV=test mix ecto.rollback --all --quiet
