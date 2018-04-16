defmodule CoindashWeb.PortfolioControllerTest do
  use CoindashWeb.ConnCase

  alias Coindash.Portfolios
  alias Coindash.Portfolios.Portfolio

  @create_attrs %{btc: 120.5}
  @update_attrs %{btc: 456.7}
  @invalid_attrs %{btc: nil}

  def fixture(:portfolio) do
    {:ok, portfolio} = Portfolios.create_portfolio(@create_attrs)
    portfolio
  end

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  describe "index" do
    test "lists all portfolios", %{conn: conn} do
      conn = get conn, portfolio_path(conn, :index)
      assert json_response(conn, 200)["data"] == []
    end
  end

  describe "create portfolio" do
    test "renders portfolio when data is valid", %{conn: conn} do
      conn = post conn, portfolio_path(conn, :create), portfolio: @create_attrs
      assert %{"id" => id} = json_response(conn, 201)["data"]

      conn = get conn, portfolio_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "btc" => 120.5}
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, portfolio_path(conn, :create), portfolio: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "update portfolio" do
    setup [:create_portfolio]

    test "renders portfolio when data is valid", %{conn: conn, portfolio: %Portfolio{id: id} = portfolio} do
      conn = put conn, portfolio_path(conn, :update, portfolio), portfolio: @update_attrs
      assert %{"id" => ^id} = json_response(conn, 200)["data"]

      conn = get conn, portfolio_path(conn, :show, id)
      assert json_response(conn, 200)["data"] == %{
        "id" => id,
        "btc" => 456.7}
    end

    test "renders errors when data is invalid", %{conn: conn, portfolio: portfolio} do
      conn = put conn, portfolio_path(conn, :update, portfolio), portfolio: @invalid_attrs
      assert json_response(conn, 422)["errors"] != %{}
    end
  end

  describe "delete portfolio" do
    setup [:create_portfolio]

    test "deletes chosen portfolio", %{conn: conn, portfolio: portfolio} do
      conn = delete conn, portfolio_path(conn, :delete, portfolio)
      assert response(conn, 204)
      assert_error_sent 404, fn ->
        get conn, portfolio_path(conn, :show, portfolio)
      end
    end
  end

  defp create_portfolio(_) do
    portfolio = fixture(:portfolio)
    {:ok, portfolio: portfolio}
  end
end
