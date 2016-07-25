defmodule GistGrouper.Post do
  use GistGrouper.Web, :model

  schema "posts" do
    field :medium_title, :string
    field :medium_id, :string
    field :github_user_id, :integer

    timestamps
  end

  def new(params \\ %{}) do
    %__MODULE__{}
    |> cast(params, [])
  end

  def create(params \\ %{}) do
    required_fields = ~w(github_user_id medium_id medium_title)

    %__MODULE__{}
    |> cast(params, required_fields)
    |> validate_required(required_fields |> Enum.map(&(&1 |> String.to_atom)))
  end
end
