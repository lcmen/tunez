defmodule Tunez.Music.Album do
  use Ash.Resource,
    otp_app: :tunez,
    domain: Tunez.Music,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshJsonApi.Resource],
    authorizers: [Ash.Policy.Authorizer]

  graphql do
    type :album
  end

  json_api do
    default_fields [:id, :name, :year, :image_url]
    includes [:tracks]
    type "album"
    derive_filter? false
  end

  postgres do
    table "albums"

    references do
      reference :artist, index?: true, on_delete: :delete
    end

    repo Tunez.Repo

    calculations_to_sql lowercase_name: "LOWER(name)"
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:name, :year, :image_url]

      argument :artist_id, :uuid, allow_nil?: false
      change manage_relationship(:artist_id, :artist, type: :append_and_remove)

      argument :tracks, {:array, :map}
      change manage_relationship(:tracks, :tracks, type: :direct_control, order_is_key: :order)
    end

    update :update do
      accept [:name, :year, :image_url]
      require_atomic? false

      argument :tracks, {:array, :map}
      change manage_relationship(:tracks, :tracks, type: :direct_control, order_is_key: :order)
    end
  end

  policies do
    bypass actor_attribute_equals(:role, :admin) do
      authorize_if always()
    end

    policy action(:create) do
      authorize_if actor_attribute_equals(:role, :editor)
    end

    policy action([:update, :destroy]) do
      authorize_if expr(^actor(:role) == :editor and ^actor(:id) == created_by_id)
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

  validations do
    validate numericality(:year, greater_than: 1950, less_than_or_equal_to: &__MODULE__.next_year/0),
      where: [present(:year)]

    validate match(:image_url, ~r"(^https://|/images/).+(\.png|\.jpg)$"),
      where: [changing(:image_url)],
      message: "must be valid url"
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
      public? true
    end

    attribute :year, :integer do
      allow_nil? false
      public? true
    end

    attribute :image_url, :string do
      public? true
    end

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    belongs_to :artist, Tunez.Music.Artist do
      allow_nil? false
    end

    belongs_to :created_by, Tunez.Accounts.User
    belongs_to :updated_by, Tunez.Accounts.User

    has_many :tracks, Tunez.Music.Track do
      sort order: :asc
      public? true
    end
  end

  calculations do
    calculate :lowercase_name, :string, expr(string_downcase(name))
    calculate :years_ago, :integer, expr(fragment("date_part('year', now()) - ?", year))
    calculate :years_ago_string, :string, expr("Released " <> years_ago <> " years ago")
    calculate :duration, :string, Tunez.Music.Calculations.SecondsToMinutes
  end

  aggregates do
    sum :duration_seconds, :tracks, :duration_seconds
  end

  def next_year, do: Date.utc_today().year + 1

  identities do
    identity :unique_name_per_artist, [:artist_id, :lowercase_name], field_names: [:name], message: "already exists"
  end
end
