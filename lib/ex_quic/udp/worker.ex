defmodule ExQuic.Udp.Worker do
   use GenServer

  alias __MODULE__

  defstruct ip: "",
            port: ""

  def start_link(args) do
    ip = Keyword.get(args, :ip)
    port = Keyword.get(args, :port)

    GenServer.start_link(__MODULE__, args, name: ExQuic.Udp.Registry.via_tuple(ip, port))
  end

  @impl true
  def init(args) do
    ip = Keyword.get(args, :ip)
    port = Keyword.get(args, :port)

    {:ok, %Worker{ip: ip, port: port}}
  end

  @impl true
  def handle_cast(bin, state) do
    IO.puts("[#{inspect state.ip}, #{inspect state.port}] Received from client: #{bin}")

    {:noreply, state}
  end
end
