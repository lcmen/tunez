defmodule Tunez.Music do
  use Ash.Domain, extensions: [AshGraphql.Domain, AshJsonApi.Domain, AshPhoenix], otp_app: :tunez

  graphql do
    queries do
      get Tunez.Music.Artist, :artist, :read
      list Tunez.Music.Artist, :artists, :search
    end

    mutations do
      create Tunez.Music.Artist, :create_artist, :create
      update Tunez.Music.Artist, :update_artist, :update
      destroy Tunez.Music.Artist, :destroy_artist, :destroy

      create Tunez.Music.Album, :create_album, :create
      update Tunez.Music.Album, :update_album, :update
      destroy Tunez.Music.Album, :destroy_album, :destroy
    end
  end

  json_api do
    routes do
      base_route "/artists", Tunez.Music.Artist do
        get :read
        index :search
        post :create
        patch :update
        delete :destroy

        related :albums, :read, primary?: true
      end

      base_route "/albums", Tunez.Music.Album do
        post :create
        patch :update
        delete :destroy
      end
    end
  end

  resources do
    resource Tunez.Music.Artist do
      define :create_artist, action: :create
      define :destroy_artist, action: :destroy
      define :read_artists, action: :read
      define :read_artist, action: :read, get_by: :id
      define :update_artist, action: :update

      define :search_artists,
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
