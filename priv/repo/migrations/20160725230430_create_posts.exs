defmodule GistGrouper.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table :posts, primary_key: false do
      add :id, :uuid, primary_key: true, default: fragment("uuid_generate_v4()")
      add :medium_title, :text, null: false, default: ""
      add :medium_id, :text, null: false
      add :github_user_id, :bigint, null: false
      add :inserted_at, :timestamptz, null: false
      add :updated_at, :timestamptz, null: false
    end

    create index :posts, [:github_user_id]
    create unique_index :posts, [:github_user_id, :medium_id]
  end
end
