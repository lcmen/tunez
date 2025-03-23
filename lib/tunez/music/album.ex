defmodule Tunez.Music.Album do
  use Ash.Resource,
    otp_app: :tunez,
    domain: Tunez.Music,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshJsonApi.Resource]

  graphql do
    type :album
  end

  json_api do
    default_fields [:id, :name, :year, :image_url]
    type "album"
  end

  postgres do
    table "albums"

    references do
      reference :artist, on_delete: :delete
    end

    repo Tunez.Repo

    calculations_to_sql lowercase_name: "LOWER(name)"
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:name, :year, :image_url, :artist_id]
    end

    update :update do
      accept [:name, :year, :image_url]
    end
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
  end

  calculations do
    calculate :lowercase_name, :string, expr(string_downcase(name))
    calculate :years_ago, :integer, expr(fragment("date_part('year', now()) - ?", year))
    calculate :years_ago_string, :string, expr("Released " <> years_ago <> " years ago")
  end

  def next_year, do: Date.utc_today().year + 1

  identities do
    identity :unique_name_per_artist, [:artist_id, :lowercase_name], field_names: [:name], message: "already exists"
  end
end
