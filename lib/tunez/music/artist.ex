defmodule Tunez.Music.Artist do
  use Ash.Resource, otp_app: :tunez, domain: Tunez.Music, data_layer: AshPostgres.DataLayer
  require Ash.Sort

  postgres do
    table "artists"
    repo Tunez.Repo
  end

  actions do
    # Actions can be executed by calling the action name directly, examples:
    # Ash.Changeset.for_create(Tunez.Music.Artist, :create, %{name: "John Doe"}) |> Ash.create
    # Ash.Query.for_read(Tunez.Music.Artist, :read) |> Ash.read
    # Ash.Changeset.for_update(artist, :update, %{name: "John Doe"}, %{id: 1}) |> Ash.update
    # Ash.Changeset.for_destroy(artist, :destroy) |> Ash.destroy
    # Ash.destroy(Tunez.Music.Artist, artist, action: :destroy, return_destroyed?: true)
    create :create do
      accept [:name, :biography]
    end

    read :read do
      primary? true
    end

    update :update do
      accept [:name, :biography]

      require_atomic? false

      # change fn changeset, _context ->
      #          new_name = Ash.Changeset.get_attribute(changeset, :name)
      #          previous_name = Ash.Changeset.get_data(changeset, :name)
      #          previous_names = Ash.Changeset.get_data(changeset, :previous_names)

      #          names =
      #            [previous_name | previous_names]
      #            |> Enum.reject(&(&1 == new_name))
      #            |> Enum.uniq()

      #          Ash.Changeset.change_attribute(changeset, :previous_names, names)
      #        end,
      #        where: [changing(:name)]
      change Tunez.Music.Changes.UpdatePreviousNames, where: [changing(:name)]
    end

    destroy :destroy
    # or you can use default actions via:
    # defaults [:create, :read, :update, :destroy]
    # default_accept [:name, :biography]
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

    attribute :previous_names, {:array, :string} do
      default []
    end

    attribute :biography, :string

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :albums, Tunez.Music.Album, sort: [year: :desc]
  end
end
