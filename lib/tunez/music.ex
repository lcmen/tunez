defmodule Tunez.Music do
  use Ash.Domain, extensions: [AshPhoenix], otp_app: :tunez

  resources do
    resource Tunez.Music.Artist do
      define :create_artist, action: :create
      define :destroy_artist, action: :destroy
      define :read_artists, action: :read
      define :read_artist, action: :read, get_by: :id
      define :update_artist, action: :update
    end
  end
end
