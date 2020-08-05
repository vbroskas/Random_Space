defmodule SpaceWeb.PageController do
  use SpaceWeb, :controller

  def index(conn, _params) do
    # get random date---
    today = DateTime.utc_now() |> DateTime.to_unix()
    new_random_day = Enum.random(803_260_800..today)

    new_random_date = DateTime.from_unix!(new_random_day) |> DateTime.to_date()

    request_url =
      "https://api.nasa.gov/planetary/apod?api_key=Tp4IT2WFMoc2dKArhDgwKjTMWhoEo1nnv5ayl3Vh&date=#{
        new_random_date
      }"

    {:ok, %{status_code: 200, body: body}} = HTTPoison.get(request_url)

    url =
      Poison.Parser.parse!(body, %{})
      |> get_in(["url"])

    render(conn, "index.html", url: url)
  end
end
