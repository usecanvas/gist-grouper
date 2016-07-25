alias GistGrouper.Router.Helpers

defmodule GistGrouper.CurrentUserPlug do
  import Phoenix.Controller
  import Plug.Conn

  def assign_current_user(conn, _opts) do
    user =
      if user_id = conn |> get_session(:current_user_id) do
        %GistGrouper.User{id: user_id}
      end

    conn
    |> assign(:current_user, user)
  end

  def ensure_current_user(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> halt
      |> redirect(to: Helpers.auth_path(conn, :login))
    end
  end

  def ensure_no_user(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
      |> halt
      |> redirect(to: Helpers.post_path(conn, :index))
    else
      conn
    end
  end
end
