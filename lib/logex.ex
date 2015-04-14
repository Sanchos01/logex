defmodule Logex do
  use Application

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
      require Logger
      def notice(bin) when is_binary(bin) do
        Discachex.memo(&logex_notice/1, [bin], unquote(ttl))
        Logger.debug bin
      end
      def warn(bin) when is_binary(bin) do
        Discachex.memo(&logex_warn/1, [bin], unquote(ttl))
        Logger.warn bin
      end
      def error(bin) when is_binary(bin) do
        Discachex.memo(&logex_error/1, [bin], unquote(ttl))
        Logger.error bin
      end
      defp logex_notice(_), do: :ok
      defp logex_warn(_), do: :ok
      defp logex_error(_), do: :ok
      defoverridable [logex_notice: 1, logex_warn: 1, logex_error: 1]
    end
  end
end
