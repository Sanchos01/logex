defmodule Logex do
  use Application
  use Silverb
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      # worker(Logex.Worker, [arg1, arg2, arg3])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Logex.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @type date :: {non_neg_integer, non_neg_integer, non_neg_integer}
  @type datetime :: {{non_neg_integer(),1 | 2 | 3 | 4 | 5 | 6 | 7 | 8 | 9 | 10 | 11 | 12,1..255},{byte(),byte(),byte()}}
  
  @spec prepare_verbose_datetime(datetime) :: String.t
  def prepare_verbose_datetime({{y, m, d},{h, min, s}}), do: "#{y}-#{zero_pad(m)}-#{zero_pad(d)} #{zero_pad(h)}:#{zero_pad(min)}:#{zero_pad(s)}"
  @spec make_verbose_datetime :: String.t
  def make_verbose_datetime, do: (:os.timestamp |> :calendar.now_to_universal_time |> prepare_verbose_datetime)
  @spec make_verbose_datetime(integer) :: String.t
  def make_verbose_datetime(delta) do
    (now_to_int(:os.timestamp) + delta)
    |> int_to_now
    |> :calendar.now_to_universal_time
    |> prepare_verbose_datetime
  end

  @spec zero_pad(String.t | integer) :: String.t
  @spec zero_pad(String.t | integer, non_neg_integer) :: String.t
  def zero_pad(string), do: zero_pad(string, 2)
  def zero_pad(string, len) when is_integer(string), do: zero_pad(:erlang.integer_to_binary(string), len)
  def zero_pad(string, len) when is_binary(string) do
    case String.length(string) do
      slen when slen >= len -> string
      slen -> << String.duplicate("0", (len - slen))::binary, string::binary >>
    end
  end

  @spec now_to_int(date) :: non_neg_integer
  def now_to_int({f,s,t}), do: (f*1000000*1000000 + s*1000000 + t)

  @spec int_to_now(integer) :: date
  def int_to_now(num) do
    {
      div(num,1000000*1000000),
      div(num,1000000) |> rem(1000000),
      rem(num,1000000)
    }
  end

  defmacro __using__([ttl: ttl]) when is_integer(ttl) do
    quote location: :keep do
      #
      # priv
      #
      defp puts_message(color, mess, lambda) do
        IO.puts("#{IO.ANSI.bright}#{__MODULE__}#{IO.ANSI.reset} : #{IO.ANSI.green}#{Logex.make_verbose_datetime}#{IO.ANSI.reset} : #{color}#{mess}#{IO.ANSI.reset}")
        lambda.(mess)
        :ok
      end
      #
      # public
      #
      def notice(bin) when is_binary(bin), do: puts_message(IO.ANSI.cyan, bin, &logex_notice/1)
      def warn(bin) when is_binary(bin), do: puts_message(IO.ANSI.yellow, bin, &logex_warn/1)
      def error(bin) when is_binary(bin), do: puts_message(IO.ANSI.red, bin, &logex_error/1)
      defp logex_notice(_), do: :ok
      defp logex_warn(_), do: :ok
      defp logex_error(_), do: :ok
      defoverridable [logex_notice: 1, logex_warn: 1, logex_error: 1, notice: 1, warn: 1, error: 1]
    end
  end
end
