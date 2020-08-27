# Space
Elixir/Phoenix app that allows clients to join different chat rooms based on a time interval(seconds). At each interval, all users in the room can discuss a different image which gets delivered from the NASA API. App uses a Dynamic Supervisor to start unique GenServer/Agent pairs, and creates different channel topics for each interval. Channels are used to transfer data between client and server, and Phoenix Presence is used to keep track of all clients joining and leaving chat channels. Any clients who join a room with a server process already running are sent the current image stored in the Agent. 

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
