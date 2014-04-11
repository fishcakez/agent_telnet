defmodule AgentTelnet.Supervisor do
  use Supervisor.Behaviour

  def start_link do
    :supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [worker(Agent, [&Map.new/0, [local: AgentTelnet]],
        modules: [AgentTelnet.Protocol])]
    supervise(children, strategy: :one_for_one)
  end
end
