defmodule Tunez.Repo.Migrations.AddAlbumTracks do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    create table(:tracks, primary_key: false) do
      add :id, :uuid, null: false, default: fragment("gen_random_uuid()"), primary_key: true
      add :order, :bigint, null: false
      add :name, :text, null: false
      add :duration_seconds, :bigint, null: false

      add :created_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :updated_at, :utc_datetime_usec,
        null: false,
        default: fragment("(now() AT TIME ZONE 'utc')")

      add :album_id,
          references(:albums,
            column: :id,
            name: "tracks_album_id_fkey",
            type: :uuid,
            prefix: "public",
            on_delete: :delete_all
          ),
          null: false
    end

    create index(:tracks, [:album_id])
  end

  def down do
    drop_if_exists index(:tracks, [:album_id])

    drop constraint(:tracks, "tracks_album_id_fkey")

    drop table(:tracks)
  end
end
