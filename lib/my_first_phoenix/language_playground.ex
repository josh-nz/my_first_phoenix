defmodule MyFirstPhoenix.LanguagePlayground do
  def foo(a \\ "default a", b) do
    IO.puts(a)
    IO.puts(b)
  end
end
