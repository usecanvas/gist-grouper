defmodule GistGrouper.MetaController do
  use GistGrouper.Web, :controller

  def health(conn, _) do
    conn |> send_resp(:ok, "OK")
  end
end
