defmodule TunezWeb.JsonApi.AlbumTest do
  use TunezWeb.ConnCase, async: true

  import AshJsonApi.Test

  test "can read an artist's albums" do
    artist = generate(artist())
    generate(album(artist_id: artist.id, name: "first!", year: 2020))
    generate(album(artist_id: artist.id, name: "second!", year: 2022))

    get(
      Tunez.Music,
      "/artists/#{artist.id}/albums",
      router: TunezWeb.AshJsonApiRouter,
      status: 200
    )
    |> assert_data_matches([
      %{"attributes" => %{"name" => "second!"}},
      %{"attributes" => %{"name" => "first!"}}
    ])
  end

  test "can create an album" do
    user = generate(user(role: :admin))
    artist = generate(artist())

    post(
      Tunez.Music,
      "/albums",
      %{
        data: %{
          attributes: %{artist_id: artist.id, name: "New JSON:API album!", year: 2015}
        }
      },
      router: TunezWeb.AshJsonApiRouter,
      status: 201,
      actor: user
    )
    |> assert_data_matches(%{
      "attributes" => %{"name" => "New JSON:API album!"}
    })
  end

  test "can update an album" do
    user = generate(user(role: :admin))
    album = generate(album())

    patch(
      Tunez.Music,
      "/albums/#{album.id}",
      %{
        data: %{
          attributes: %{name: "Updated name", year: 2001}
        }
      },
      router: TunezWeb.AshJsonApiRouter,
      status: 200,
      actor: user
    )
    |> assert_data_matches(%{
      "attributes" => %{"name" => "Updated name"}
    })
  end

  test "can delete an album" do
    user = generate(user(role: :admin))
    album = generate(album(name: "Test"))

    delete(
      Tunez.Music,
      "/albums/#{album.id}",
      router: TunezWeb.AshJsonApiRouter,
      status: 200,
      actor: user
    )
    |> assert_data_matches(%{
      "attributes" => %{"name" => "Test"}
    })
  end
end
