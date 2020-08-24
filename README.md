# Space
Elixir/Phoenix app using a Dynamic Supervisor to start unique instance pairs of a GenServer and Agent. This app will query the NASA API to display a random space image every interval (default 15 sec). The user has the option of changing the interval or killing the process. If killed, the process is designed to restart with the most recent interval.

The client interval also dictates which chat room they are currently subscribed to. Whenever they change intervals they will also change chat rooms.

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `npm install` inside the `assets` directory
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix
