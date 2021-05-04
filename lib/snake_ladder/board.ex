defmodule SnakeLadder.Board do
  require Integer
  def new do
    100..1
    |> Enum.chunk_every(10)
    |> Enum.with_index()
    |> Enum.map(fn {x, i} ->
      if Integer.is_odd(i), do: Enum.reverse(x), else: x
    end)
  end
end
