defmodule AgentTelnet.Mixfile do
  use Mix.Project

  def project do
    [app: :agent_telnet,
     version: "0.0.1",
     elixir: "~> 0.13.0-dev",
     deps: deps]
  end

  def application do
    [ applications: [:xgen, :ranch, :core],
      mod: { AgentTelnet, [] } ]
  end

  defp deps do
    [{ :xgen, github: "josevalim/xgen" },
      { :ranch, github: "extend/ranch", ref: "c1d0c4571e" },
      { :core, github: "fishcakez/core", ref: "900e1c09b4" },
      { :exrm, github: "bitwalker/exrm", tag: "0.4.2" }]
  end
end
