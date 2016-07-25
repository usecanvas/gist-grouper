defmodule GistGrouper.PostController do
  use GistGrouper.Web, :controller

  plug :ensure_current_user

  def index(conn, _params) do
    conn
    |> render(:index)
  end
end
