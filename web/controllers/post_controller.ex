alias GistGrouper.{ErroView, Post}

defmodule GistGrouper.PostController do
  use GistGrouper.Web, :controller

  plug :ensure_current_user

  def new(conn, _params) do
    conn
    |> render(:new, changeset: Post.new)
  end

  def create(conn, params) do
    changeset =
      params
      |> Map.get("post")
      |> Map.put("github_user_id", conn.assigns.current_user.id)
      |> Post.create

    case changeset |> Repo.insert do
      {:ok, post} ->
        conn
        |> redirect(to: post_path(conn, :show, post))
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(:new, changeset: changeset)
    end
  end

  def index(conn, _params) do
    posts =
      from(p in Post,
           where: p.github_user_id == ^conn.assigns.current_user.id,
           order_by: [desc: p.inserted_at])
      |> Repo.all

    conn
    |> render(:index, posts: posts)
  end

  def show(conn, %{"id" => id}) do
    post = conn |> get_post(id)

    case conn |> get_post(id) do
      nil ->
        conn
        |> not_found
      post ->
        conn
        |> render(:show, post: post)
    end
  end

  def delete(conn, %{"id" => id}) do
    post = conn |> get_post(id)

    case conn |> get_post(id) do
      nil ->
        conn
        |> not_found
      post ->
        post |> Repo.delete!

        conn
        |> redirect(to: post_path(conn, :index))
    end
  end

  defp get_post(conn, id) do
    from(p in Post,
         where: p.id == ^id,
         where: p.github_user_id == ^conn.assigns.current_user.id)
     |> Repo.one
  end

  defp not_found(conn) do
    conn
    |> put_status(:not_found)
    |> render(ErrorView, "404.html")
  end
end
