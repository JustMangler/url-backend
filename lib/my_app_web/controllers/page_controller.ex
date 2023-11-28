defmodule MyAppWeb.PageController do
  use MyAppWeb, :controller

  require Logger

  alias AppName.Links
  alias AppName.Links.Link

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, layout: false)
  end
end
