defmodule ExQuic.Udp.Registry do
  def start_link() do
    Registry.start_link(keys: :unique, name: __MODULE__, partitions: System.schedulers_online())
  end

  def via_tuple(ip, port) do
    {:via, Registry, {__MODULE__, {ip, port}}}
  end

   def child_spec(_) do
    Supervisor.child_spec(
      Registry,
      id: __MODULE__,
      start: {__MODULE__, :start_link, []}
    )
  end
end
