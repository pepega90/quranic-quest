defmodule ReqWeb.ReqLive.Index do
  use ReqWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="container">
      <h1>Quranic Quest</h1>
      <input class="form-control" phx-keydown="cari" name="surah" placeholder="Cari surah..." />
      <div class="row">
      <%= for d <- @data do %>
        <div class="col-md-4 mt-3">
        <div class="card">
          <div class="card-body">
            <div class="d-flex justify-content-between">
              <h5 class="card-title"><%= d["asma"]["id"]["short"] %> (<%= d["asma"]["translation"]["id"] %>)</h5>
              <p><%= d["asma"]["ar"]["short"] %></p>
            </div>
            <p class="card-text"><%= d["ayahCount"] %> Ayat</p>
            <a href={~p"/surah/#{d["number"]}"} class="btn btn-warning">Baca</a>
          </div>
        </div>
        </div>
      <% end %>
      </div>
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    url = "https://quran-endpoint.vercel.app/quran"

    url |> HTTPoison.get()
        |> case  do
      {:ok, %{status_code: 200, body: body}} ->
        res = Poison.decode!(body)
        %{"data" => data} = res
        {:ok, socket |> assign(data: data, prevData: data)}

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts "++++ ERROR ++++"
        IO.inspect reason
        {:ok, socket |> assign(data: [], prevData: [])}
    end
  end

  @impl true
  def handle_event("cari", %{"key" => key, "value" => surah} = _params, %{assigns: %{prevData: prev}} = socket) do
    key |> case do
      _ ->
        updated_data = Enum.filter(prev, fn e -> String.contains?(String.downcase(e["asma"]["id"]["short"]), surah) end)
        {:noreply, socket |> assign(data: updated_data)}
    end
  end

end
