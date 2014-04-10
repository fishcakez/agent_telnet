defmodule AgentTelnet do
  use Application.Behaviour

  def start(_type, _args) do
    case start_listener() do
      { :ok, _ } ->
        AgentTelnet.Supervisor.start_link
      { :error, _reason } = error ->
        error
    end
  end

  def stop(_) do
    :ok = :ranch.stop_listener(__MODULE__)
  end

  ## internal

  defp start_listener() do
    :ranch.start_listener(__MODULE__, 1, :ranch_tcp,
      [ip: { 127, 0, 0, 1}, port: 8023],
      AgentTelnet.Protocol, [])
  end

end
