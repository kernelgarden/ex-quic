defmodule ExQuic.Application do
  use Application

  def start(_type, _args) do
    Supervisor.start_link(
      [
        ExQuic.Udp.Supervisor,
        ExQuic.Udp.Registry,
        ExQuic.Server
      ],
      strategy: :one_for_one
    )
  end

end
