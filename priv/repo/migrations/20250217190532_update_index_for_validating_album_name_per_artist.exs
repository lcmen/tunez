defmodule Tunez.Repo.Migrations.UpdateIndexForValidatingAlbumNamePerArtist do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    drop_if_exists unique_index(:albums, ["(LOWER(name))", :artist_id],
                     name: "albums_unique_name_per_artist_index"
                   )

    create unique_index(:albums, [:artist_id, "(LOWER(name))"],
             name: "albums_unique_name_per_artist_index"
           )
  end

  def down do
    drop_if_exists unique_index(:albums, [:artist_id, "(LOWER(name))"],
                     name: "albums_unique_name_per_artist_index"
                   )

    create unique_index(:albums, ["(LOWER(name))", :artist_id],
             name: "albums_unique_name_per_artist_index"
           )
  end
end
