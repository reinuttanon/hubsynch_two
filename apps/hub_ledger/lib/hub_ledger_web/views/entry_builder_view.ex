defmodule HubLedgerWeb.EntryBuilderView do
  use HubLedgerWeb, :view

  def background("credit") do
    "has-background-link"
  end

  def background("debit") do
    "has-background-info"
  end

  def json_field(%{"string" => string, "values" => values}, 1) do
    ~s({
    "string": "#{string}",
    "values": ["#{values}"]
  })
  end

  def json_field(%{"string" => string, "values" => values}, 2) do
    ~s({
      "string": "#{string}",
      "values": [#{values}]
  })
  end

  def json_field(%{"object" => object, "uid" => uid}, 2) do
    ~s({
      "object": "#{object}",
      "uid": ["#{uid}"]
  })
  end

  def json_field(field, _), do: ~s("#{field}")
end
