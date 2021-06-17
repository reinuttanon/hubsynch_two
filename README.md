# HubsynchTwo


## Prerequisites
* Elixir at least version 1.11.2 with Erlang/OTP 23
* Postgres at least version 13.2
* Openssl
* Gcc
* Xcode (for mac) 

To start Hubsync 2.0 services:

  * run `mix setup`
    * This should get dependancies
    * Setup your databases
    * install node modules
    * seed the databases
  * Start Phoenix endpoint with `mix phx.server`

Now you can use the api at [`localhost:4001`](http://localhost:4001).

## Production deployment
Currently using Elixir 1.11.2 (compiled with Erlang/OTP 23)
For production deployment run these commands in a Linux or Mac machine with Elixir and Erlang installed.
Ensure you have the environmental variables installed.

- set -a; source .env.prod;
- npm run deploy --prefix ./assets
- mix phx.digest
- mix release
- _build/prod/rel/hub_identity/bin/hub_identity eval "HubIdentity.Release.migrate"
- _build/prod/rel/hub_identity/bin/hub_identity start
### To connect to remotely to a running server
- _build/prod/rel/hub_identity/bin/hub_identity remote

### Server Environment
Application is currently running as a service with systemctl, the file is located at /etc/systemd/system/hub_identity.service
- Check the status: systemctl status hub_identity.service
- Restart: sudo systemctl restart hub_identity.service
- Stop: sudo systemctl stop hub_identity.service
- Start: sudo systemctl start hub_identity.service
- Check logs: journalctl -u hub_identity.service | tail -50
