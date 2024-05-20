defmodule VisualsAdmin.HyperionFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `VisualsAdmin.Hyperion` context.
  """

  @doc """
  Generate a mapping.
  """
  def mapping_fixture(attrs \\ %{}) do
    {:ok, mapping} =
      attrs
      |> Enum.into(%{

      })
      |> VisualsAdmin.Hyperion.create_mapping()

    mapping
  end
end
