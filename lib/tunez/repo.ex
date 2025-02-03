defmodule Tunez.Repo do
  use AshPostgres.Repo, otp_app: :tunez

  @spec first(Ash.Resource.t()) :: Ash.Resource.t() | nil
  def first(model) do
    model |> Ecto.Query.first() |> one()
  end

  def installed_extensions do
    # Add extensions here, and the migration generator will install them.
    ["ash-functions"]
  end

  # Don't open unnecessary transactions
  # will default to `false` in 4.0
  def prefer_transaction? do
    false
  end

  @spec min_pg_version() :: Version.t()
  def min_pg_version do
    %Version{major: 14, minor: 0, patch: 0}
  end
end
