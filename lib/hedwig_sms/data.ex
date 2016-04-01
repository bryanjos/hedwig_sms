defmodule Hedwig.Adapters.SMS.Data do
  defstruct [
    :from,
    :body
  ]


  @doc """
  Converts body from an http request into a Data struct to be sent to the adapter
  """
  def to_data(body) when is_binary(body) do
    to_data URI.decode_query(body)
  end

  def to_data(body) when is_map(body) do

    %Hedwig.Adapters.SMS.Data{
      from: body["From"],
      body: body["Body"]
    }
  end
end
