defmodule TunezWeb.Albums.FormLive do
  use TunezWeb, :live_view

  on_mount {TunezWeb.LiveUserAuth, role_required: [:admin, :editor]}

  def mount(params, _session, socket) do
    {form, artist} = form_for(params, socket)

    socket =
      socket
      |> assign(:form, to_form(form))
      |> assign(:artist, artist)
      |> assign(:page_title, "New Album")

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <Layouts.app {assigns}>
      <.header>
        <.h1>{@page_title}</.h1>
      </.header>

      <.simple_form :let={form} id="album_form" as={:form} for={@form} phx-change="validate" phx-submit="save" >
        <.input name="artist_id" label="Artist" value="" disabled />
        <div class="sm:flex gap-8 space-y-8 md:space-y-0">
          <div class="sm:w-3/4"><.input field={form[:name]} label="Name" /></div>
          <div class="sm:w-1/4">
            <.input field={form[:year]} label="Year" type="number" />
          </div>
        </div>
        <.input field={form[:image_url]} label="Cover Image URL" />


        <.track_inputs form={form} />

        <:actions>
          <.button type="primary">Save</.button>
        </:actions>
      </.simple_form>
    </Layouts.app>
    """
  end

  def track_inputs(assigns) do
    ~H"""
    <.h2>Tracks</.h2>

    <table class="w-full">
      <thead class="border-b border-zinc-100">
        <tr>
          <th class=""></th>
          <th class="text-left font-medium text-sm pb-1 px-3">Name</th>
          <th class="text-left font-medium text-sm pb-1 px-3" colspan="2">Duration</th>
        </tr>
      </thead>
      <tbody phx-hook="trackSort" id="trackSort">
        <.inputs_for :let={track_form} field={@form[:tracks]}>
          <tr data-id={track_form.index}>
            <td class="px-3 w-20">
              <span class="hero-bars-3 handle cursor-pointer" />
            </td>
            <td class="px-3">
              <label for={track_form[:name].id} class="hidden">Name</label>
              <.input field={track_form[:name]} />
            </td>
            <td class="px-3 w-36">
              <label for={track_form[:duration].id} class="hidden">Duration</label>
              <.input field={track_form[:duration]} />
            </td>
            <td class="w-12">
              <.button_link phx-click="remove-track" phx-value-path={track_form.name} kind="error" size="xs" inverse>
                <span class="hidden">Delete</span>
                <.icon name="hero-trash" class="size-5" />
              </.button_link>
            </td>
          </tr>
        </.inputs_for>
      </tbody>
    </table>

    <.button_link phx-click="add-track" kind="primary" size="sm" inverse>
      Add Track
    </.button_link>
    """
  end

  def handle_event("validate", %{"form" => form_data}, socket) do
    socket = update(socket, :form, &AshPhoenix.Form.validate(&1, form_data))
    {:noreply, socket}
  end

  def handle_event("save", %{"form" => form_data}, socket) do
    socket =
      case AshPhoenix.Form.submit(socket.assigns.form, params: form_data) do
        {:ok, album} ->
          socket
          |> put_flash(:info, "Album saved successfully.")
          |> push_navigate(to: "/artists/#{album.artist_id}")

        {:error, form} ->
          socket
          |> assign(:form, form)
          |> put_flash(:error, "Failed to save album.")
      end

    {:noreply, socket}
  end

  def handle_event("add-track", _params, socket) do
    socket =
      update(socket, :form, fn form ->
        AshPhoenix.Form.add_form(form, :tracks)
      end)

    {:noreply, socket}
  end

  def handle_event("remove-track", %{"path" => path}, socket) do
    socket =
      update(socket, :form, fn form ->
        AshPhoenix.Form.remove_form(form, path)
      end)

    {:noreply, socket}
  end

  def handle_event("reorder-tracks", %{"order" => order}, socket) do
    socket =
      update(socket, :form, fn form ->
        AshPhoenix.Form.sort_forms(form, [:tracks], order)
      end)

    {:noreply, socket}
  end

  defp form_for(%{"id" => album_id}, %{assigns: %{current_user: current_user}}) do
    album = Tunez.Music.read_album!(album_id, actor: current_user, load: [:artist, :tracks])

    form =
      Tunez.Music.form_to_update_album(album, actor: current_user)
      |> AshPhoenix.Form.ensure_can_submit!()

    {form, album.artist}
  end

  defp form_for(%{"artist_id" => artist_id}, %{assigns: %{current_user: current_user}}) do
    artist = Tunez.Music.read_artist!(artist_id, actor: current_user)

    form =
      Tunez.Music.form_to_create_album(
        actor: current_user,
        transform_params: fn _form, params, _context ->
          Map.put(params, "artist_id", artist.id)
        end
      )
      |> AshPhoenix.Form.ensure_can_submit!()

    {form, artist}
  end
end
