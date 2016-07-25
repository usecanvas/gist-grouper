defmodule GistGrouper.MetaController do
  use GistGrouper.Web, :controller

  def health(conn, _) do
    conn |> send_resp(:ok, "OK")
  end

  def root(conn, _) do
    if conn.private[:current_user] do
      conn
      |> redirect(to: post_path(conn, :index))
    else
      conn
      |> redirect(to: auth_path(conn, :login))
    end
  end
end
