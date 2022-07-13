defmodule Accounting do
  @moduledoc """
  This module assumes the existence of a folder invoices/ with all invoices in
  XML format. To use, just run
  
      iex> process_parallel()
  
  """

  def handle_error(invoice) do
    IO.puts(:stderr, "#{invoice} does not have a valid vNF field")
    0.0
  end

  @doc """
  Receives an invoice in XML format and returns its value.

  ## Examples

      iex> Accounting.get_value("invoices/4387172425.xml")
      112.79

  """
  def get_value(invoice) do
  #  NEXT: 
  #  - make vNF a default parameter, perhaps use get_value(invoice, fields \\ ["vNF"])  
  
    {:ok, fileasstring} = File.read(invoice)

#    Regex.run(~r'<vNF>\d+.\d*</vNF>', fileasstring)
#      |> hd
#      |> String.replace(["<vNF>", "</vNF>"], "") 
#      |> String.to_float
      
    case Regex.run(~r'<vNF>\d+.\d*</vNF>', fileasstring) do
      nil -> handle_error(invoice)
      [pattern] -> 
        try do 
          pattern
            |> String.replace(["<vNF>", "</vNF>"], "") 
            |> String.to_float
        rescue
          _e in ArgumentError -> handle_error(invoice)
        end
    end
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
