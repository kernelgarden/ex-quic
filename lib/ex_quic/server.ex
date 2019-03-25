defmodule ExQuic.Server do
  use GenServer

  alias __MODULE__
  alias ExQuic.Udp

  defstruct bind_port: 0

  def start_link(args) do
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  @impl true
  def init(args) do
    port = Keyword.get(args, :port, 6060)

    sock =
      case :gen_udp.open(port, [
        :binary,
        {:active, false},
      ]) do
        {:ok, sock} ->
          sock

        {:error, reason} ->
          raise "#{inspect reason}"
      end

    :gen_udp.controlling_process(sock, self())

    :inet.setopts(sock, active: true)

    IO.puts("Listen On 6060!")

    {:ok, %Server{bind_port: port}}
  end

  @impl true
  def handle_info({:udp, _sock, ip, port, bin}, state) do
    IO.puts("Received from #{inspect ip}, #{inspect port} : #{inspect bin}")
    GenServer.cast(Udp.Supervisor.worker(ip, port), bin)
    {:noreply, state}
  end

  def handle_info(unknown_msg, state) do
    IO.puts("Received unknown msg! #{unknown_msg}")
    {:noreply, state}
  end
end
