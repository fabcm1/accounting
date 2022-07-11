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
    {:ok, fileasstring} = File.read(invoice)

    Regex.run(~r'<vNF>\d+.\d*</vNF>', fileasstring)
      |> hd
      |> String.replace(["<vNF>", "</vNF>"], "") 
      |> String.to_float
  end
#  NEXT: make vNF a default parameter
end
