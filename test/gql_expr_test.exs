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

  test "build expr query with multiple exprs" do
    q =
      GqlBuilder.query(gql_type: :apples, fields: [{:nodes, [:fieldId, :variety]}])
      |> Query.add_expr(gql_type: :page_info, fields: [:end_cursor, :has_next_page])

    assert "query {\n  apples {\n    nodes {\n      fieldId\n      variety\n    }\n  }\n  pageInfo {\n    endCursor\n    hasNextPage\n  }\n}" ==
             GqlBuilder.build(q)
  end

  test "build expr query with nested fields and multiple exprs" do
    q =
      GqlBuilder.query(
        gql_type: :apples,
        fields: [{:nodes, [:fieldId, :variety, {:farmer, [:last_name]}]}]
      )
      |> Query.add_expr(gql_type: :page_info, fields: [:end_cursor, :has_next_page])

    assert "query {\n  apples {\n    nodes {\n      fieldId\n      variety\n      farmer {\n        lastName\n      }\n    }\n  }\n  pageInfo {\n    endCursor\n    hasNextPage\n  }\n}" ==
             GqlBuilder.build(q)
  end

  test "build expr query with args, nested fields, and multiple exprs" do
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

  test "build expr query with nested fields on subexpr" do
    q =
      GqlBuilder.query(
        gql_type: :holdings,
        args: [farmer: "Simpson"],
        subexpr: [
          gql_type: :orchards,
          args: [after: "abcd"],
          fields: [{:nodes, [:id, :location]}, {:page_info, [:end_cursor, :has_next_page]}]
        ]
      )

    assert "query {\n  holdings(farmer: \"Simpson\") {\n    orchards(after: \"abcd\") {\n      " <>
             "nodes {\n        id\n        location\n      }\n      pageInfo {\n        " <>
             "endCursor\n        hasNextPage\n      }\n    }\n  }\n}" ==
             GqlBuilder.build(q)
  end

  test "build expr query with union" do
    q =
      GqlBuilder.query(
        gql_type: :holdings,
        args: [farmer: "Simpson"],
        fields: [:id],
        subexpr: [
          gql_type: :Transaction_events,
          args: [last: 10],
          subexpr: [
            gql_type: :nodes,
            fields: [{:union_on, :Closed_sale_event, [:id, :created_at]}]
          ]
        ]
      )

    assert "query {\n  holdings(farmer: \"Simpson\") {\n    TransactionEvents(last: 10) {\n      nodes {\n        ...on ClosedSaleEvent {\n          id\n          createdAt\n        }\n      }\n    }\n  }\n}"
    GqlBuilder.build(q)
  end
end
