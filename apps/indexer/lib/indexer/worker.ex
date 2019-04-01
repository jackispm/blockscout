defmodule Indexer.Worker do
  @moduledoc """
  Generates default supervisors for indexer workers.
  """

  defmacro __using__(opts) do
    strategy = Keyword.get(opts, :strategy, :one_for_all)

    quote location: :keep do
      Module.create(
        __MODULE__.Supervisor,
        quote bind_quoted: [strategy: unquote(strategy), worker: __MODULE__, task_supervisor: __MODULE__.TaskSupervisor] do
          use Supervisor

          def child_spec([]), do: child_spec([[], []])
          def child_spec([init_arguments]), do: child_spec([init_arguments, []])

          def child_spec([_init_arguments, _gen_server_options] = start_link_arguments) do
            default = %{
              id: __MODULE__,
              start: {__MODULE__, :start_link, start_link_arguments},
              restart: :transient,
              type: :supervisor
            }

            Supervisor.child_spec(default, [])
          end

          def start_link(arguments, gen_server_options \\ []) do
            if disabled?() do
              :ignore
            else
              Supervisor.start_link(__MODULE__, arguments, Keyword.put_new(gen_server_options, :name, __MODULE__))
            end
          end

          def disabled?() do
            Application.get_env(:indexer, unquote(worker), [])[:disabled?] == true
          end

          @impl Supervisor
          def init(worker_arguments) do
            children = [
              {Task.Supervisor, name: unquote(task_supervisor)},
              {unquote(worker), [Keyword.put(worker_arguments, :supervisor, self()), [name: unquote(worker)]]}
            ]

            Supervisor.init(children, strategy: unquote(strategy))
          end
        end,
        Macro.Env.location(__ENV__)
      )
    end
  end
end
