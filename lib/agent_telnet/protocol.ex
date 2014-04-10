defmodule AgentTelnet.Protocol do

  @behaviour :ranch_protocol
  use Core.Behaviour
  use Core.Sys.Behaviour

  ## ranch api

  def start_link(ref, socket, transport, _) do
    pid = Core.spawn_link(__MODULE__, { ref, socket, transport })
    { :ok, pid }
  end

  ## Core api

  def init(parent, { ref, socket, transport }) do
    Core.init_ack()
    :ok = transport.setopts(socket, [packet: :line, packet_size: 100])
    :ok = :ranch.accept_ack(ref)
    :ok = transport.setopts(socket, [active: :once])
    loop(%{transport: transport, socket: socket}, parent)
  end

  ## Core.Sys api

  def system_continue(state, parent), do: loop(state, parent)

  def system_terminate(state, parent, reason) do
    terminate(state, parent, reason)
  end

  ## internal

  defp loop(%{transport: transport, socket: socket} = state, parent) do
    { data, closed, error } = transport.messages()
    Core.Sys.receive(__MODULE__, state, parent) do
      { ^data, ^socket, packet } ->
        transport.setopts(socket, [active: :once])
        handle_data(packet, state)
        loop(state, parent)
      { ^closed, ^socket } ->
        terminate(state, parent, :normal)
      { ^error, ^socket, reason } ->
        terminate(state, parent, reason)
    after
      60_000 ->
        terminate(state, parent, :timeout)
    end
  end

  defp handle_data(packet, state) do
    decode_packet(packet)
      |> handle_packet(state)
      |> send_result(state)
  end

  defp terminate(%{transport: transport, socket: socket} = state, parent,
      reason) do
    send_result({ :stop, reason }, state)
    :ok = transport.close(socket)
    Core.stop(__MODULE__, state, parent, reason)
  end

  defp decode_packet(packet) do
    regex =
    ~r/^\s*(?|(put)\s+(\w+)\s+(\w+)|(get)\s+(\w+)|(delete)\s+(\w+)|(stop))\s*$/
    case Regex.run(regex, packet, []) do
      [_, "put", key, value] ->
        { :put, key, value }
      [_, "get", key] ->
        { :get, key }
      [_, "delete", key] ->
        { :delete, key }
      [_, "stop"] ->
        :stop
      nil ->
        { :badpacket, packet }
    end
  end

  defp handle_packet({ :put, key, value }, _state) do
    Agent.update(AgentTelnet, &Map.put(&1, key, value))
  end

  defp handle_packet({ :get, key }, _state) do
    { :ok, Agent.get(AgentTelnet, &Map.get(&1, key)) }
  end

  defp handle_packet({ :delete, key }, _state) do
    Agent.update(AgentTelnet, &Map.delete(&1, key))
  end

  defp handle_packet(:stop, %{transport: transport, socket: socket}) do
    transport.shutdown(socket, :read)
  end

  defp handle_packet({ :badpacket, _packet } = reason, _state) do
    { :error, reason}
  end

  defp send_result(packet, state) do
    encode_packet(packet)
      |> send_data(state)
  end

  defp encode_packet(:ok), do: "ok\n"
  defp encode_packet({ :ok, value }), do: [to_string(value), ?\n]
  defp encode_packet({ :error, reason }), do: ["Error: ", inspect(reason), ?\n]
  defp encode_packet({ :stop, reason }), do: ["Closing: ", inspect(reason), ?\n]

  defp send_data(data, %{transport: transport, socket: socket}) do
    transport.send(socket, data)
  end

end
