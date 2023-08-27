defmodule ReqWeb.ReqLive.Show do
  use ReqWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
        <div class="container">
            <h1><%= @data["asma"]["id"]["long"] %></h1>
            <p><%= @data["tafsir"]["id"] %></p>
            <%= for a <- @data["ayahs"] do %>
              <div class="col mt-3">
              <div class="card tilt">
                <div class="card-body">
                  <h5 class="card-title text-right"><%= a["text"]["ar"] %></h5>
                  <h6 class="card-text"><%= a["translation"]["id"] %></h6>
                  <p class="card-text"><%= a["text"]["read"] %></p>
                  <audio class="recit" controls style="width:100%;">
                    <source src={a["audio"]["url"]} type="audio/mp3">
                  Your browser does not support the audio element.
                  </audio>
                </div>
              </div>
              </div>
            <% end %>
        </div>
        <script>

            let listRecit = document.querySelectorAll(".recit");

            listRecit[0].addEventListener("play", (e) => {
              e.currentTarget.parentElement.style.backgroundColor = "green";
              e.currentTarget.parentElement.style.color = "white";
            })

            listRecit.forEach((audio, i) => {
              audio.addEventListener("ended", () => {

                audio.parentElement.style.backgroundColor = "white";
                audio.parentElement.style.color = "black";

                if(i < listRecit.length - 1) {
                  listRecit[i + 1].play();
                  listRecit[i+1].parentElement.style.backgroundColor = "green";
                  listRecit[i+1].parentElement.style.color = "white";
                }

              })

            })

            /*
                Credit code below
                https://codepen.io/technokami/pen/abojmZa
             */
            /* Store the element in el */
              let listEl = document.querySelectorAll('.tilt')

              listEl.forEach(el => {

               /* Get the height and width of the element */
              const height = el.clientHeight
              const width = el.clientWidth

              /*
                * Add a listener for mousemove event
                * Which will trigger function 'handleMove'
                * On mousemove
                */
              el.addEventListener('mousemove', handleMove)

              /* Define function a */
              function handleMove(e) {
                /*
                  * Get position of mouse cursor
                  * With respect to the element
                  * On mouseover
                  */
                /* Store the x position */
                const xVal = e.layerX
                /* Store the y position */
                const yVal = e.layerY

                /*
                  * Calculate rotation valuee along the Y-axis
                  * Here the multiplier 20 is to
                  * Control the rotation
                  * You can change the value and see the results
                  */
                const yRotation = 20 * ((xVal - width / 2) / width)

                /* Calculate the rotation along the X-axis */
                const xRotation = -20 * ((yVal - height / 2) / height)

                /* Generate string for CSS transform property */
                const string = 'perspective(500px) scale(1.1) rotateX(' + xRotation + 'deg) rotateY(' + yRotation + 'deg)'

                /* Apply the calculated transformation */
                el.style.transform = string
              }

              /* Add listener for mouseout event, remove the rotation */
              el.addEventListener('mouseout', function() {
                el.style.transform = 'perspective(500px) scale(1) rotateX(0) rotateY(0)'
              })

              /* Add listener for mousedown event, to simulate click */
              el.addEventListener('mousedown', function() {
                el.style.transform = 'perspective(500px) scale(0.9) rotateX(0) rotateY(0)'
              })

              /* Add listener for mouseup, simulate release of mouse click */
              el.addEventListener('mouseup', function() {
                el.style.transform = 'perspective(500px) scale(1.1) rotateX(0) rotateY(0)'
              })

              })
        </script>
    """
  end

  @impl true
  def mount(%{"id" => id} = _params, _session, socket) do
    url = "https://quran-endpoint.vercel.app/quran/#{id}"

    url |> HTTPoison.get()
        |> case do
      {:ok, %{status_code: 200, body: body}} ->
        res = Poison.decode!(body)
        %{"data" => data} = res
        {:ok, socket |> assign(data: data)}

      {:error, %HTTPoison.Error{reason: reason}} ->
        IO.puts "++++ ERROR ++++"
        IO.inspect reason
        {:ok, socket |> assign(data: [])}
    end
  end
end
