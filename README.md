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
- cd apps/dashboard && npm run deploy --prefix ./assets
- mix phx.digest
- cd ../..
- mix release

### Database migrations after release
-  _build/prod/rel/hubsynch_two/bin/hubsynch_two eval "HubCrm.ReleaseTasks.migrate"
-  _build/prod/rel/hubsynch_two/bin/hubsynch_two eval "HubIdentity.ReleaseTasks.migrate"
-  _build/prod/rel/hubsynch_two/bin/hubsynch_two eval "HubLedger.ReleaseTasks.migrate"
-  _build/prod/rel/hubsynch_two/bin/hubsynch_two eval "HubPayments.ReleaseTasks.migrate"

- _build/prod/rel/hubsynch_two/bin/hubsynch_two start
### To connect to remotely to a running server
- _build/prod/rel/hubsynch_two/bin/hubsynch_two remote

### Server Environment
Application is currently running as a service with systemctl, the file is located at /etc/systemd/system/hubsynch_two.service
- Check the status: systemctl status hubsynch_two.service
- Restart: sudo systemctl restart hubsynch_two.service
- Stop: sudo systemctl stop hubsynch_two.service
- Start: sudo systemctl start hubsynch_two.service
- Check logs: journalctl -u hubsynch_two.service | tail -50
