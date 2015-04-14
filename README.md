Logex
=====

Example :

iex(1)> defmodule Some do
...(1)> use Logex, ttl: 1000
...(1)> defp logex_error(bin), do: IO.puts "AAAAA"
...(1)> end

iex(2)> Some.notice "qwe"

19:49:53.811 [debug] qwe
:ok
iex(3)> Some.warn "qwe"

19:49:59.888 [warn]  qwe
:ok
iex(4)> Some.error "qwe"
AAAAA

19:50:03.840 [error] qwe
:ok
