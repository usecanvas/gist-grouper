defmodule GistGrouper.Repo.Migrations.CreateUuidExtension do
  use Ecto.Migration

  def up do
    execute ~s(CREATE EXTENSION IF NOT EXISTS "uuid-ossp")
  end

  def down, do: nil
end
