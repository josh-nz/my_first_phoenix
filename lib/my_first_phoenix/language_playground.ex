defmodule MyFirstPhoenix.LanguagePlayground do
  # foo(single_arg) will match this 2 arity fun,
  # with b = single_arg, a = default.
  def foo(a \\ "default a", b) do
    IO.puts(a)
    IO.puts(b)
  end

  # Fun pattern matching is dependent on fun
  # ordering. As ordered below, bar(:name) will
  # print "bar(any)".
  def bar(any) do
    IO.puts("bar(any)")
  end

  def bar(:name) do
    IO.puts("bar(:name)")
  end

  # Compile error:
  # cannot invoke def/2 inside function/macro
  # def baz() do
  #   def innerf do
  #     IO.puts("innerf")
  #   end

  #   innerf()
  # end
end
