# AgentTelnet

Install
-------
```
git clone https://github.com/fishcakez/agent_telnet.git
cd agent_telnet
git checkout v0.0.1
mix do deps.get, compile, release
git checkout v0.0.2
mix do compile, release
mkdir -p example/releases/0.0.2/
tar -xif rel/agent_telnet/agent_telnet-0.0.1.tar.gz -C example/
cp rel/agent_telnet/agent_telnet-0.0.2.tar.gz example/releases/0.0.2/agent_telnet.tar.gz
```

Example
------
Start two terminals

In first terminal:
```
cd example
bini/agent_telnet start
```
In second terminal:
```
telnet 127.0.0.1 8023
put key value
get key
delete key
```
In first terminal:
```
bin/agent_telnet upgrade "0.0.2"
```
In second terminal:
```
get key
put key value
get key
delete key
```
In first terminal:
```
bin/agent_telnet downgrade "0.0.1"
```
In second terminal:
```
get key
put key value
get key
delete key
stop
```
