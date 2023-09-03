# AppleConnect

AppleConnect is a small Swift wrapper around a Network TCP stream on the local network (using Bonjour for discovery). While the transport is bidirectional, the API is designed around a "service" provided by a single server and connected to by potentially many clients.

## Usage

Setup for servers differs a little bit from clients. Once a connection is established, the channel is identical from both ends. All connections are encrypted using TLS-PSK derived from a shared key of your choosing.

> [!IMPORTANT]  
> For security, you should generate the shared key using cryptographically appropriate random data. Sharing this key should be done out-of-band and is out of scope for AppleConnect. For user-facing applications, one way you might do this is by generating a code on one device and asking the user to confirm it on the second one.

### Setting up the server

A typical server should advertise its availability using `Connection.advertise(forServiceType:name:key:)`. Attempts by clients to connect will show up as `NWConnection` objects, which you can pass to `Connection.init(connection:)` to complete the connection process.

### Setting up the client

A client should browse for servers it wants to connect to. `Connection.endpoints(forServiceType:)` will asynchronously stream a list of available `NWEndpoint`s, and once you've found an endpoint that you'd like to connect to, call `Connection.init(endpoint:key:)` to establish the connection using the shared encryption key.

### Transferring data

Both clients and servers can send data to each other using `Connection.send(data:)`, and receive data by watching `Connection.data`.
