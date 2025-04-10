defmodule Tunez.Music.Artist do
  use Ash.Resource,
    otp_app: :tunez,
    domain: Tunez.Music,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshJsonApi.Resource],
    authorizers: [Ash.Policy.Authorizer]

  require Ash.Sort

  graphql do
    type :artist
    filterable_fields [:albums_count, :created_at, :latest_album_year, :updated_at]
  end

  json_api do
    default_fields [:id, :name, :biography, :albums_count, :image_url, :latest_album_year]
    includes albums: [:tracks]
    type "artist"
    derive_filter? false
  end

  postgres do
    table "artists"
    repo Tunez.Repo

    custom_indexes do
      index "name gin_trgm_ops", name: "artists_name_index", using: "GIN"
    end
  end

  resource do
    description "A person or group of people that makes and releases music."
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

    read :search do
      description "List Artists, optionally filtering by name."

      argument :query, :ci_string do
        description "Return only artists with names including the given value."

        constraints allow_empty?: true
        default ""
      end

      filter expr(contains(name, ^arg(:query)))

      pagination offset?: true, default_limit: 8
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

  policies do
    bypass actor_attribute_equals(:role, :admin) do
      authorize_if always()
    end

    policy action(:update) do
      authorize_if actor_attribute_equals(:role, :editor)
    end

    policy action_type(:read) do
      authorize_if always()
    end
  end

  changes do
    change relate_actor(:created_by, allow_nil?: true), on: :create
    change relate_actor(:updated_by, allow_nil?: true), on: :create
    change relate_actor(:updated_by, allow_nil?: false), on: :update
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
      public? true
    end

    attribute :previous_names, {:array, :string} do
      default []
      public? true
    end

    attribute :biography, :string do
      public? true
    end

    create_timestamp :created_at, public?: true
    update_timestamp :updated_at, public?: true
  end

  relationships do
    belongs_to :created_by, Tunez.Accounts.User
    belongs_to :updated_by, Tunez.Accounts.User

    has_many :albums, Tunez.Music.Album do
      sort year: :desc
      public? true
    end
  end

  aggregates do
    count :albums_count, :albums do
      public? true
    end

    first :image_url, :albums, :image_url do
      public? true
    end

    first :latest_album_year, :albums, :year do
      public? true
    end
  end
end
