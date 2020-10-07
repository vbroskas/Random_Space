// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket,
// and connect at the socket path in "lib/web/endpoint.ex".
//
// Pass the token on params as below. Or remove it
// from the params if you are not using authentication.
import { Socket, Presence } from "phoenix"

let socket = new Socket("/socket", { params: { token: window.userToken, user_id: window.user_id, username: window.username } })

if (window.userToken) {

	let imgContainer = document.querySelector("#url")
	let intervalContainer = document.querySelector("#interval")
	let intervalInput = document.querySelector("#interval-input")
	let chatInput = document.querySelector("#chat-input")
	let messagesContainer = document.querySelector("#messages")
	var space
	join_space(window.defaultChannel)

	intervalInput.addEventListener("keypress", event => {
		if (event.key === 'Enter') {
			let interval = intervalInput.value
			intervalInput.value = ""
			// join new space room
			console.log("about to change space")
			change_room(interval)
		}
	})

	chatInput.addEventListener("keypress", event => {
		if (event.key === 'Enter') {
			console.log("ENTER")
			space.push("new_msg", { body: chatInput.value })
			chatInput.value = ""
		}
	})



	function join_space(interval) {
		space = socket.channel(`space:${interval}`)
		space.join()
			.receive("ok", resp => { console.log("Joined space!", resp) })
			.receive("error", resp => { console.log("Unable to join space", resp) })

		space.onError(() => console.log("there was an error!"))
		space.onClose(() => console.log("the channel has gone away gracefully"))

		// get presence info for chatroom
		get_presence(space)

		space.on("new_interval", payload => { new_interval(payload) })
		space.on("new_url", payload => { new_url(payload) })
		space.on("new_msg", payload => { new_message(payload) })

	}

	function change_room(interval) {
		console.log("chat about to leave is..")
		console.log(space)
		space.leave()
		messagesContainer.innerHTML = ""
		join_space(interval)
	}

	function renderOnlineUsers(presence) {
		let response = ""
		presence.list((id, { metas: [first, ...rest] }) => {
			id = slice_id(id)
			response += `<br>${id}</br>`
		})

		document.querySelector("#pres").innerHTML = response
	}

	function get_presence(space) {
		var presence = new Presence(space)

		// listen for the "presence_state" and "presence_diff" events
		presence.onSync(() => {
			document.querySelector("#pres").innerHTML = ""
			renderOnlineUsers(presence)
		})

		// detect if user has joined for the 1st time or from another tab/device
		presence.onJoin((id, current, newPres) => {
			id = slice_id(id)
			if (!current) {
				console.log(`${id} Has joined the channel!`)
			}
		})

		// detect if user has left from all tabs/devices, or is still present
		presence.onLeave((id, current, leftPres) => {
			if (current.metas.length === 0) {
				console.log(`${id} Has left the channel!`)
			} else {
				console.log(`${id} Has left from a device!`)
			}
		})

	}

	function new_interval(payload) {
		intervalContainer.innerHTML = payload.interval
	}

	function new_url(payload) {
		let imgItem = document.createElement("img")
		imgItem.src = payload.url
		imgItem.classList.add("space-img")
		imgContainer.innerHTML = ''
		imgContainer.appendChild(imgItem)
	}

	function new_message(payload) {
		let messageItem = document.createElement("p")
		messageItem.innerText = `[${slice_id(payload.client_id)}] ${payload.body}`
		messagesContainer.appendChild(messageItem)
	}


	socket.connect()
	socket.onOpen(() => console.log('chatSocket connected'))

} // --end if window.userToken




// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "lib/web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "lib/web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/3" function
// in "lib/web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket, _connect_info) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, connect to the socket:










export default socket



