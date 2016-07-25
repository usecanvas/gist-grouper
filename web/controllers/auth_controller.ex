defmodule GistGrouper.AuthController do
  use GistGrouper.Web, :controller
  import Application, only: [fetch_env!: 2]

  @github_client_id fetch_env!(:gist_grouper, :github_client_id)
  @github_client_secret fetch_env!(:gist_grouper, :github_client_secret)

  plug :ensure_current_user when action in [:logout]
  plug :ensure_no_user when action in [:login, :callback]
  plug :ensure_valid_state when action in [:callback]

  def login(conn, _params) do
    conn
    |> render(:login)
  end

  def logout(conn, _params) do
    conn
    |> clear_session
    |> redirect(to: auth_path(conn, :login))
  end

  def callback(conn, params) do
    state = conn.private.state

    with {:ok, access_token} <- get_access_token(params["code"], state),
         {:ok, user_id} <- get_user_id(access_token) do
      conn
      |> put_session(:current_user_id, user_id)
      |> redirect(to: post_path(conn, :index))
    else
      _ ->
        conn
        |> send_resp(:internal_server_error, "Unable to fetch user data")
    end

    conn
    |> send_resp(:ok, "OK")
  end

  defp ensure_valid_state(conn, _opts) do
    with state when is_binary(state) <- conn.query_params["state"],
         {:ok, token} <- state |> Base.decode64(padding: false),
         true <- valid_token?(token) do
      conn
      |> put_private(:state, state)
    else
      _ ->
        conn
        |> halt
        |> send_resp(:forbidden, "Invalid OAuth callback state")
    end
  end

  defp get_access_token(nil, _), do: {:error, "No code provided"}
  defp get_access_token(code, state) do
    resp =
      HTTPoison.post(
        "https://github.com/login/oauth/access_token",
        Poison.encode!(%{
          client_id: @github_client_id,
          client_secret: @github_client_secret,
          code: code,
          state: state
        }),
        "accept": "application/json",
        "content-type": "application/json")

    case resp do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body |> Poison.decode! |> Map.get("access_token")}
      _ ->
        {:error, "Unable to get access token"}
    end
  end

  defp get_user_id(access_token) do
    resp =
      HTTPoison.get(
        "https://api.github.com/user",
        "accept": "application/json",
        "authorization": "token #{access_token}")

    case resp do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body |> Poison.decode! |> Map.get("id")}
      _ ->
        {:error, "Unable to get user"}
    end
  end

  defp valid_token?(token) do
    case Phoenix.Token.verify(GistGrouper.Endpoint, "state", token) do
      {:ok, _url} -> true
      _ -> false
    end
  end
end
