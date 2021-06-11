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
