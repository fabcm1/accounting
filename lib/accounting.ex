defmodule Accounting do
  @moduledoc """
  This module assumes the existence of a folder invoices/ with all invoices in
  XML format. To use, just run
  
      iex> process_parallel()
  
  """

  def handle_error(invoice) do
    IO.puts(:stderr, "#{invoice} does not have a valid vNF field")
    Decimal.new(0)
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
  #  - replace Decimal with Money
  #  - try to find the contents in the fileasstring without using regex
  #  - get the emission date of the invoice
  
    {:ok, fileasstring} = File.read(invoice)
      
    case Regex.run(~r'<vNF>\d+\.\d\d</vNF>', fileasstring) do
      nil -> handle_error(invoice)
      [match] -> 
        match
         |> String.replace(["<vNF>", "</vNF>"], "") 
         |> Decimal.new
    end
  end
  
  def process_sequential() do
    Path.wildcard("invoices/*.xml")
      |> Enum.reduce(Decimal.new(0), fn (invoice, acc) -> Decimal.add(acc, get_value(invoice)) end)
  end
  
  def process_parallel() do
  # NEXT:
  # - remake the concurrency using a supervised process
  
    Path.wildcard("invoices/*.xml")
      |> Task.async_stream(&get_value/1)
      |> Enum.reduce(Decimal.new(0), fn ({:ok, value}, acc) -> Decimal.add(value, acc) end)
  end
  
end
