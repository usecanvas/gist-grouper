defmodule GistGrouper.AuthView do
  use GistGrouper.Web, :view

  @github_client_id Application.fetch_env!(:gist_grouper, :github_client_id)

  defp github_login_url do
    "https://github.com/login/oauth/authorize?client_id=#{@github_client_id}"
    |> append_state
  end

  defp append_state(url) do
    state =
      Phoenix.Token.sign(GistGrouper.Endpoint, "state", url)
      |> Base.encode64(padding: false)

    url <> "&state=#{state}"
  end
end
