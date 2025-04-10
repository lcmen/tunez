defmodule Tunez.Music.Changes.MinutesToSeconds do
  use Ash.Resource.Change

  @format ~r/^\d+:\d{2}$/

  def change(changeset, _opts, _context) do
    {:ok, duration} = Ash.Changeset.fetch_argument(changeset, :duration)

    if String.match?(duration, @format) do
      seconds = to_seconds(duration)
      Ash.Changeset.change_attribute(changeset, :duration_seconds, seconds)
    else
      Ash.Changeset.add_error(changeset, field: :duration, message: "Use mm:ss format.")
    end
  end

  defp to_seconds(duration) do
    [minutes, seconds] = String.split(duration, ":", parts: 2)
    String.to_integer(minutes) * 60 + String.to_integer(seconds)
  end
end
