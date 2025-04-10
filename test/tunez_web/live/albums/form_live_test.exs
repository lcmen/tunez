defmodule TunezWeb.Albums.FormLiveTest do
  use TunezWeb.ConnCase, async: true

  alias Tunez.Music, warn: false

  describe "creating a new album" do
    test "errors for forbidden users", %{conn: conn} do
      artist = generate(artist())

      conn
      |> insert_and_authenticate_user()
      |> visit(~p"/artists/#{artist}/albums/new")
      |> assert_has(flash(:error), text: "Unauthorized")
    end

    test "succeeds when valid details are entered", %{conn: conn} do
      artist = generate(artist())

      conn
      |> insert_and_authenticate_user(:admin)
      |> visit(~p"/artists/#{artist}/albums/new")
      |> fill_in("Name", with: "Final Days")
      |> fill_in("Year", with: 2021)
      |> click_button("Save")
      |> assert_has(flash(:info), text: "Album saved successfully")

      album = get_by_name!(Tunez.Music.Album, "Final Days")
      assert album.artist_id == artist.id
    end

    test "track data can be added and removed for an album", %{conn: conn} do
      artist = generate(artist())

      conn
      |> insert_and_authenticate_user(:admin)
      |> visit(~p"/artists/#{artist}/albums/new")
      |> fill_in("Name", with: "Sample With Tracks")
      |> fill_in("Year", with: 2021)
      |> click_link("Add Track")
      |> click_link("Add Track")
      |> click_link("Add Track")
      |> fill_in("tr[data-id=0] input", "Name", with: "First Track")
      |> fill_in("tr[data-id=0] input", "Duration", with: "2:22")
      |> fill_in("tr[data-id=1] input", "Name", with: "Second Track")
      |> fill_in("tr[data-id=1] input", "Duration", with: "3:33")
      |> fill_in("tr[data-id=2] input", "Name", with: "Third Track")
      |> fill_in("tr[data-id=2] input", "Duration", with: "4:44")
      |> click_button("Save")
      |> assert_has(flash(:info), text: "Album saved successfully")

      album = get_by_name!(Tunez.Music.Album, "Sample With Tracks", load: [:tracks])
      assert ["First Track", "Second Track", "Third Track"] == Enum.map(album.tracks, & &1.name)
    end

    test "fails when invalid details are entered", %{conn: conn} do
      artist = generate(artist())

      conn
      |> insert_and_authenticate_user(:admin)
      |> visit(~p"/artists/#{artist}/albums/new")
      |> fill_in("Name", with: "Missing Year")
      |> click_button("Save")
      |> assert_has(flash(:error), text: "Failed to save album.")

      refute get_by_name(Tunez.Music.Artist, "Missing Year")
    end
  end

  describe "updating an existing album" do
    test "errors for forbidden users", %{conn: conn} do
      album = generate(album())

      conn
      |> insert_and_authenticate_user()
      |> visit(~p"/albums/#{album}/edit")
      |> assert_has(flash(:error), text: "Unauthorized")
    end

    test "succeeds when valid details are entered", %{conn: conn} do
      album = generate(album(name: "Old Name"))

      conn
      |> insert_and_authenticate_user(:admin)
      |> visit(~p"/albums/#{album}/edit")
      |> fill_in("Name", with: "New Name")
      |> click_button("Save")
      |> assert_has(flash(:info), text: "Album saved successfully")

      album = Music.read_album!(album.id)
      assert album.name == "New Name"
    end

    test "fails when invalid details are entered", %{conn: conn} do
      album = generate(album(name: "Old Name"))

      conn
      |> insert_and_authenticate_user(:admin)
      |> visit(~p"/albums/#{album}/edit")
      |> fill_in("Name", with: "")
      |> click_button("Save")
      |> assert_has(flash(:error), text: "Failed to save album.")

      album = Music.read_album!(album.id)
      assert album.name == "Old Name"
    end
  end
end
