defmodule TunezWeb.Artists.FormLiveTest do
  use TunezWeb.ConnCase, async: true

  alias Tunez.Music, warn: false

  describe "creating a new artist" do
    test "errors for forbidden users", %{conn: conn} do
      conn
      |> insert_and_authenticate_user()
      |> visit(~p"/artists/new")
      |> assert_has(flash(:error), text: "Unauthorized")
    end

    test "succeeds when valid details are entered", %{conn: conn} do
      conn
      |> insert_and_authenticate_user(:admin)
      |> visit(~p"/artists/new")
      |> fill_in("Name", with: "Temperance")
      |> click_button("Save")
      |> assert_has(flash(:info), text: "Artist saved successfully")

      assert get_by_name(Tunez.Music.Artist, "Temperance")
    end

    test "fails when invalid details are entered", %{conn: conn} do
      conn
      |> insert_and_authenticate_user(:admin)
      |> visit(~p"/artists/new")
      |> fill_in("Name", with: "")
      |> click_button("Save")
      |> assert_has(flash(:error), text: "Failed to save artist.")

      assert Music.read_artists!() == []
    end
  end

  describe "updating an existing artist" do
    test "errors for forbidden users", %{conn: conn} do
      artist = generate(artist())

      conn
      |> insert_and_authenticate_user()
      |> visit(~p"/artists/#{artist}/edit")
      |> assert_has(flash(:error), text: "Unauthorized")
    end

    test "succeeds when valid details are entered", %{conn: conn} do
      artist = generate(artist(name: "Old Name"))

      conn
      |> insert_and_authenticate_user(:admin)
      |> visit(~p"/artists/#{artist}/edit")
      |> fill_in("Name", with: "New Name")
      |> click_button("Save")
      |> assert_has(flash(:info), text: "Artist saved successfully")

      updated_artist = Music.read_artist!(artist.id)
      assert updated_artist.name == "New Name"
    end

    test "fails when invalid details are entered", %{conn: conn} do
      artist = generate(artist(name: "Old Name"))

      conn
      |> insert_and_authenticate_user(:admin)
      |> visit(~p"/artists/#{artist}/edit")
      |> fill_in("Name", with: "")
      |> click_button("Save")
      |> assert_has(flash(:error), text: "Failed to save artist.")

      updated_artist = Music.read_artist!(artist.id)
      assert updated_artist.name == "Old Name"
    end
  end
end
