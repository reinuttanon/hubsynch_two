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

## Localhost deployment with HubVault
After initial setup this can be run with vault using Erlang Distributed Protocol by first starting the Vault with:
```bash
iex --sname vault@localhost -S mix phx.server
```
Then start hubsynch_two with:
```bash
iex --sname hubsynch_two@localhost -S mix phx.server
```
To confirm once you are in an iex shell (using `-S`) run the following command:
```elixir
iex> Node.list()
```
You should see `[:vault@localhost]` or `[:hubsynch_two@localhost]` depending on which server your iex shell is connected to.

## Localhost deployment with MnesiaManager
After initial setup this can be run with vault using Erlang Distributed Protocol by first starting the MnesiaManager following the instructions on the README at MnesiaManager Repo.
Go to `apps/hub_cluster/config/dev.exs` and read the comments and uncomment the correct `config` settings to enable this service to connect with MnesiaManager. (don't forget to comment out the other config settings!)

Then start this service with:
```bash
iex --sname hubsynch_two@localhost -S mix phx.server
```
This service should startup, connect to MnesiaManager and synch tables.

## Localhost deployment with MnesiaManager and HubVault
Follow instructions for MnesiaManager and start that service. For example:
In one terminal in the MnesiaManger app:
```bash
iex --sname mnesia_manager@localhost -S mix
```
In second terminal in the HubVault app:
```bash
iex --sname vault@localhost -S mix phx.server
```
In third terminal from this app:
```bash
iex --sname hubsynch_two@localhost -S mix phx.server
```
You will have a full distributed network of all 3 services connected and :mnesia synching tables with backup.

## Production deployment
Currently using Elixir 1.11.2 (compiled with Erlang/OTP 23)
For production deployment run these commands in a Linux or Mac machine with Elixir and Erlang installed.
Ensure you have the environmental variables installed.

- set -a; source .env.prod;
- git pull
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

mix phx.gen.context ClientServices PaymentConfig payment_configs client_service_uuid:string payment_methods:{:array, :string} statement_name:string uuid:string provider_id:references:providers
