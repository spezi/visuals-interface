defmodule VisualsAdminWeb.MappingLiveTest do
  use VisualsAdminWeb.ConnCase

  import Phoenix.LiveViewTest
  import VisualsAdmin.HyperionFixtures

  @create_attrs %{}
  @update_attrs %{}
  @invalid_attrs %{}

  defp create_mapping(_) do
    mapping = mapping_fixture()
    %{mapping: mapping}
  end

  describe "Index" do
    setup [:create_mapping]

    test "lists all mappings", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/mappings")

      assert html =~ "Listing Mappings"
    end

    test "saves new mapping", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/mappings")

      assert index_live |> element("a", "New Mapping") |> render_click() =~
               "New Mapping"

      assert_patch(index_live, ~p"/mappings/new")

      assert index_live
             |> form("#mapping-form", mapping: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#mapping-form", mapping: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/mappings")

      html = render(index_live)
      assert html =~ "Mapping created successfully"
    end

    test "updates mapping in listing", %{conn: conn, mapping: mapping} do
      {:ok, index_live, _html} = live(conn, ~p"/mappings")

      assert index_live |> element("#mappings-#{mapping.id} a", "Edit") |> render_click() =~
               "Edit Mapping"

      assert_patch(index_live, ~p"/mappings/#{mapping}/edit")

      assert index_live
             |> form("#mapping-form", mapping: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#mapping-form", mapping: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/mappings")

      html = render(index_live)
      assert html =~ "Mapping updated successfully"
    end

    test "deletes mapping in listing", %{conn: conn, mapping: mapping} do
      {:ok, index_live, _html} = live(conn, ~p"/mappings")

      assert index_live |> element("#mappings-#{mapping.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#mappings-#{mapping.id}")
    end
  end

  describe "Show" do
    setup [:create_mapping]

    test "displays mapping", %{conn: conn, mapping: mapping} do
      {:ok, _show_live, html} = live(conn, ~p"/mappings/#{mapping}")

      assert html =~ "Show Mapping"
    end

    test "updates mapping within modal", %{conn: conn, mapping: mapping} do
      {:ok, show_live, _html} = live(conn, ~p"/mappings/#{mapping}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Mapping"

      assert_patch(show_live, ~p"/mappings/#{mapping}/show/edit")

      assert show_live
             |> form("#mapping-form", mapping: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#mapping-form", mapping: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/mappings/#{mapping}")

      html = render(show_live)
      assert html =~ "Mapping updated successfully"
    end
  end
end
