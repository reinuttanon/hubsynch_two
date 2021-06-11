# HubCrm

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can use the api at [`localhost:4001`](http://localhost:4001).

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Production deployment
Currently using Elixir 1.11.2 (compiled with Erlang/OTP 23)
For production deployment run these commands in a Linux or Mac machine with Elixir and Erlang installed.
Ensure you have the environmental variables installed.

- set -a; source .env.prod;
- mix release
- _build/prod/rel/hub_crm/bin/hub_crm start
### To connect to remotely to a running server
- _build/prod/rel/hub_crm/bin/hub_crm remote

### Server Environment
Application is currently running as a service with systemctl, the file is located at /etc/systemd/system/hub_crm.service
- Check the status: systemctl status hub_crm.service
- Restart: sudo systemctl restart hub_crm.service
- Stop: sudo systemctl stop hub_crm.service
- Start: sudo systemctl start hub_crm.service
- Check logs: journalctl -u hub_crm.service | tail -50
