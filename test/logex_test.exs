defmodule LogexTest do
  use ExUnit.Case
  use Logex, [ttl: 1000]

  def logex_notice(bin), do: IO.puts "some data to handle notice #{bin}"
  def logex_warn(bin), do: IO.puts "some data to handle warn #{bin}"
  def logex_error(bin), do: IO.puts "some data to handle error #{bin}"

  test "check it works" do
    Enum.each(1..100, fn(_) -> 
    	LogexTest.notice("hello, classy!")
    	LogexTest.warn("hello, classy!")
    	LogexTest.error("hello, classy!")
    end)
  end
end
