# HubIdentity

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

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
