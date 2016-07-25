defmodule GistGrouper.Router do
  use GistGrouper.Web, :router

  import GistGrouper.CurrentUserPlug

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :assign_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", GistGrouper do
    pipe_through :browser # Use the default browser stack

    get "/", MetaController, :root
    get "/health", MetaController, :health

    get "/login", AuthController, :login
    get "/logout", AuthController, :logout
    get "/oauth/github/callback", AuthController, :callback

    resources "/posts", PostController, only: [:new, :create, :index, :show, :delete]
  end

  # Other scopes may use custom stacks.
  # scope "/api", GistGrouper do
  #   pipe_through :api
  # end
end
