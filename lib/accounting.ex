defmodule Accounting do
  @moduledoc """
  Documentation for `Accounting`.
  """

  
  @doc """
  Receives an invoice in xml format and returns its value.

  ## Examples

      iex> Accounting.get_value("invoices/4387172425.xml")
      112.79

  """
  def get_value(invoice) do
  #  NEXT: 
  #  - make vNF a default parameter, perhaps use get_value(invoice, fields \\ ["vNF"])
  #  - handle errors     
  
  # IO.puts(:stderr, "message")
  
    {:ok, fileasstring} = File.read(invoice)

    Regex.run(~r'<vNF>\d+.\d*</vNF>', fileasstring)
      |> hd
      |> String.replace(["<vNF>", "</vNF>"], "") 
      |> String.to_float
  end
  
  def process_sequential() do
    Path.wildcard("invoices/*.xml")
      |> Enum.reduce(0.0, fn (invoice, acc) -> acc + get_value(invoice) end)
  end
  
  def process_parallel() do
    Path.wildcard("invoices/*.xml")
      |> Task.async_stream(&get_value/1)
      |> Enum.reduce(0.0, fn ({:ok, value}, acc) -> value + acc end)
  end

end
