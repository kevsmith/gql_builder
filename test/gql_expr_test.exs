defmodule GqlBuilder.GqlExprTest do
  use ExUnit.Case, async: true

  alias GqlBuilder.Query

  test "build simple expr query" do
    q =
      GqlBuilder.query(
        gql_type: :apples,
        fields: [:field_id, :variety, :plantedAt]
      )

    assert "query {\n  apples {\n    fieldId\n    variety\n    plantedAt\n  }\n}" ==
             GqlBuilder.build(q)
  end

  test "build expr query with args" do
    q =
      GqlBuilder.query(
        gql_type: :apples,
        args: [farmer: "Simpson"],
        fields: [:field_id, :variety, :plantedAt]
      )

    assert "query {\n  apples(farmer: \"Simpson\") {\n    fieldId\n    variety\n    plantedAt\n  }\n}" ==
             GqlBuilder.build(q)
  end

  test "build expr query with nested fields" do
    q =
      GqlBuilder.query(
        gql_type: :apples,
        fields: [:field_id, :variety, :planted_at, {:farmer, [:last_name]}]
      )

    assert "query {\n  apples {\n    fieldId\n    variety\n    plantedAt\n    farmer {\n      lastName\n    }\n  }\n}" ==
             GqlBuilder.build(q)
  end

  test "build expr query with nested fields and args" do
    q =
      GqlBuilder.query(
        gql_type: :apples,
        args: [farmer: "Simpson"],
        fields: [:field_id, :variety, :planted_at, {:farmer, [:id]}]
      )

    assert "query {\n  apples(farmer: \"Simpson\") {\n    fieldId\n    variety\n    plantedAt\n    farmer {\n      id\n    }\n  }\n}" ==
             GqlBuilder.build(q)
  end

  test "build expr query with subexpr" do
    q =
      GqlBuilder.query(gql_type: :apples, fields: [{:nodes, [:fieldId, :variety]}])
      |> Query.add_expr(gql_type: :page_info, fields: [:end_cursor, :has_next_page])

    assert "query {\n  apples {\n    nodes {\n      fieldId\n      variety\n    }\n  }\n  pageInfo {\n    endCursor\n    hasNextPage\n  }\n}" ==
             GqlBuilder.build(q)
  end

  test "build expr query with nested fields and subexpr" do
    q =
      GqlBuilder.query(
        gql_type: :apples,
        fields: [{:nodes, [:fieldId, :variety, {:farmer, [:last_name]}]}]
      )
      |> Query.add_expr(gql_type: :page_info, fields: [:end_cursor, :has_next_page])

    assert "query {\n  apples {\n    nodes {\n      fieldId\n      variety\n      farmer {\n        lastName\n      }\n    }\n  }\n  pageInfo {\n    endCursor\n    hasNextPage\n  }\n}" ==
             GqlBuilder.build(q)
  end

  test "build expr query with args, nested fields, and subexpr" do
    q =
      GqlBuilder.query(
        gql_type: :apples,
        args: [farmer: "Simpson"],
        fields: [{:nodes, [:fieldId, :variety, {:farmer, [:id]}]}]
      )
      |> Query.add_expr(gql_type: :page_info, fields: [:end_cursor, :has_next_page])

    assert "query {\n  apples(farmer: \"Simpson\") {\n    nodes {\n      fieldId\n      variety\n      farmer {\n        id\n      }\n    }\n  }\n  pageInfo {\n    endCursor\n    hasNextPage\n  }\n}" ==
             GqlBuilder.build(q)
  end
end
