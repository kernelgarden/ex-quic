defmodule ExQuic.Udp.Supervisor do
  use DynamicSupervisor

  require Logger

  @spec start_link(any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(args \\ []) do
    DynamicSupervisor.start_link(__MODULE__, args, name: __MODULE__)
  end

  @spec worker(integer(), integer()) :: any()
  def worker(ip, port) do
    case start(ip, port) do
      {:ok, worker_pid} -> worker_pid
      {:error, {:already_started, worker_pid}} -> worker_pid
    end
  end

  defp start(ip, port) do
    DynamicSupervisor.start_child(__MODULE__, {ExQuic.Udp.Worker, ip: ip, port: port})
  end

  @impl true
  @spec init(any()) ::
          {:ok,
           %{
             extra_arguments: [any()],
             intensity: non_neg_integer(),
             max_children: :infinity | non_neg_integer(),
             period: pos_integer(),
             strategy: :one_for_one
           }}
  def init(_args) do
    Process.flag(:trap_exit, true)

    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @spec handle_info({:EXIT, any(), any()}, any()) :: {:noreply, any()}
  def handle_info({:EXIT, from, reason}, state) do
    Logger.error(fn -> "player #{inspect(from)} is down. reason: #{inspect(reason)}" end)
    {:noreply, state}
  end
end
