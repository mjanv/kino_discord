defmodule KinoDiscord.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    Kino.SmartCell.register(KinoDiscord.MessageCell)

    Supervisor.start_link([], strategy: :one_for_one, name: KinoSlack.Supervisor)
  end
end
