defmodule Tunez.Music do
  use Ash.Domain, extensions: [AshPhoenix], otp_app: :tunez

  resources do
    resource Tunez.Music.Artist do
      define :create_artist, action: :create
      define :destroy_artist, action: :destroy
      define :read_artists, action: :read
      define :read_artist, action: :read, get_by: :id
      define :update_artist, action: :update

      define :search_artist,
        action: :search,
        args: [:query],
        default_options: [load: [:albums_count, :latest_album_year, :image_url]]
    end

    resource Tunez.Music.Album do
      define :create_album, action: :create
      define :update_album, action: :update
      define :destroy_album, action: :destroy
      define :read_album, action: :read, get_by: :id
    end
  end
end
