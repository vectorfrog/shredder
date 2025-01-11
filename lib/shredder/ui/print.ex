defmodule Shredder.UI.Print do
  import Owl.IO, only: [puts: 2]
  import Owl.Data, only: [tag: 2]

  def green(message) do
    puts(tag(message, :green), :stderr)
  end
  def red(message) do
    puts(tag(message, :red), :stderr)
  end
  def yellow(message) do
    puts(tag(message, :yellow), :stderr)
  end
  def cyan(message) do
    puts(tag(message, :cyan), :stderr)
  end
  def blue(message) do
    puts(tag(message, :blue), :stderr)
  end

def map(map) when is_map(map) do
  table_maker([map])
end

def list(list) when is_list(list) do
  table_maker(list)
end

def table_maker(list) when is_list(list) do
 Owl.Table.new(list,
   render_cell: [
     header: fn
       k when is_atom(k) -> (":" <> Atom.to_string(k)) |> Owl.Data.tag(:yellow)
       k when is_binary(k) -> k |> Owl.Data.tag(:blue)
     end,
     body: fn
       v when is_atom(v) -> ":" <> Atom.to_string(v) |> Owl.Data.tag(:yellow)
       v when is_number(v) -> to_string(v) |> Owl.Data.tag(:green)
       v when is_binary(v) -> v |> Owl.Data.tag(:blue)
       v -> to_string(v)
     end
   ],
   sort_columns: fn a, b ->
     case {a, b} do
       {:id, _} -> true
       {_, :id} -> false
       {a, b} -> to_string(a) <= to_string(b)
     end
   end
 )
 |> puts(:stderr)
end

end
