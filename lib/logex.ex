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

  defmacro __using__([ttl: ttl]) when is_integer(ttl) do
    quote location: :keep do
      #
      # priv
      #
      defp puts_message(color, mess, lambda) do 
        lambda.(mess)
        IO.puts("#{IO.ANSI.bright}#{__MODULE__}#{IO.ANSI.reset} : #{IO.ANSI.green}#{Exutils.make_verbose_datetime}#{IO.ANSI.reset} : #{color}#{mess}#{IO.ANSI.reset}") 
      end
      #
      # public
      #
      def notice(bin) when is_binary(bin), do: Tinca.memo(&puts_message/3, [IO.ANSI.cyan, bin, &logex_notice/1], unquote(ttl))
      def warn(bin) when is_binary(bin), do: Tinca.memo(&puts_message/3, [IO.ANSI.yellow, bin, &logex_warn/1], unquote(ttl))
      def error(bin) when is_binary(bin), do: Tinca.memo(&puts_message/3, [IO.ANSI.red, bin, &logex_error/1], unquote(ttl))
      defp logex_notice(_), do: :ok
      defp logex_warn(_), do: :ok
      defp logex_error(_), do: :ok
      defoverridable [logex_notice: 1, logex_warn: 1, logex_error: 1, notice: 1, warn: 1, error: 1]
    end
  end
end
