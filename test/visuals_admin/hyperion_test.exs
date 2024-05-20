defmodule VisualsAdmin.HyperionTest do
  use VisualsAdmin.DataCase

  alias VisualsAdmin.Hyperion

  describe "mappings" do
    alias VisualsAdmin.Hyperion.Mapping

    import VisualsAdmin.HyperionFixtures

    @invalid_attrs %{}

    test "list_mappings/0 returns all mappings" do
      mapping = mapping_fixture()
      assert Hyperion.list_mappings() == [mapping]
    end

    test "get_mapping!/1 returns the mapping with given id" do
      mapping = mapping_fixture()
      assert Hyperion.get_mapping!(mapping.id) == mapping
    end

    test "create_mapping/1 with valid data creates a mapping" do
      valid_attrs = %{}

      assert {:ok, %Mapping{} = mapping} = Hyperion.create_mapping(valid_attrs)
    end

    test "create_mapping/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Hyperion.create_mapping(@invalid_attrs)
    end

    test "update_mapping/2 with valid data updates the mapping" do
      mapping = mapping_fixture()
      update_attrs = %{}

      assert {:ok, %Mapping{} = mapping} = Hyperion.update_mapping(mapping, update_attrs)
    end

    test "update_mapping/2 with invalid data returns error changeset" do
      mapping = mapping_fixture()
      assert {:error, %Ecto.Changeset{}} = Hyperion.update_mapping(mapping, @invalid_attrs)
      assert mapping == Hyperion.get_mapping!(mapping.id)
    end

    test "delete_mapping/1 deletes the mapping" do
      mapping = mapping_fixture()
      assert {:ok, %Mapping{}} = Hyperion.delete_mapping(mapping)
      assert_raise Ecto.NoResultsError, fn -> Hyperion.get_mapping!(mapping.id) end
    end

    test "change_mapping/1 returns a mapping changeset" do
      mapping = mapping_fixture()
      assert %Ecto.Changeset{} = Hyperion.change_mapping(mapping)
    end
  end
end
