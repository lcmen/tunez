defmodule TunezWeb.Artists.FormLive do
  use TunezWeb, :live_view

  def mount(params, _session, socket) do
    form = form_for(params)

    socket =
      socket
      |> assign(:form, to_form(form))
      |> assign(:page_title, "New Artist")

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app {assigns}>
      <.header>
        <.h1>{@page_title}</.h1>
      </.header>

      <.simple_form
        :let={form}
        id="artist_form"
        as={:form}
        for={@form}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={form[:name]} label="Name" />
        <.input field={form[:biography]} type="textarea" label="Biography" />
        <:actions>
          <.button type="primary">Save</.button>
        </:actions>
      </.simple_form>
    </Layouts.app>
    """
  end

  def handle_event("validate", %{"form" => form_data}, socket) do
    socket = update(socket, :form, &AshPhoenix.Form.validate(&1, form_data))
    {:noreply, socket}
  end

  def handle_event("save", %{"form" => form_data}, socket) do
    socket =
      case AshPhoenix.Form.submit(socket.assigns.form, params: form_data) do
        {:ok, artist} ->
          socket
          |> put_flash(:info, "Artist saved successfully.")
          |> push_navigate(to: "/artists/#{artist.id}")

        {:error, form} ->
          socket
          |> assign(:form, form)
          |> put_flash(:error, "Failed to save artist.")
      end

    {:noreply, socket}
  end

  defp form_for(%{"id" => artist_id}) do
    artist = Tunez.Music.read_artist!(artist_id)
    Tunez.Music.form_to_update_artist(artist)
  end

  defp form_for(_) do
    Tunez.Music.form_to_create_artist()
  end
end
