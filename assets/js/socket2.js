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
	let chatEnterBtn = document.querySelector("#enter-chat-btn")
	let countdownContainer = document.querySelector("#countdown")
	let explanationContainer = document.querySelector('#explanation')
	const intervalForm = document.getElementById('interval-form');
	var space

	join_space(window.defaultChannel)

	intervalForm.addEventListener("submit", event => {
		let interval = document.getElementById('interval-input').value;
		let int = parseInt(interval)

		if ((int % 1 != 0) || (Number(int) == NaN) || (int < 10)) {
			console.log("bad Interval")
			interval.classList.add("interval-error")

		} else {
			change_room(int)
			intervalInput.value = ""

		}
	})


	chatInput.addEventListener("keypress", event => {
		if (event.key === 'Enter') {

			space.push("new_msg", { body: chatInput.value })
			chatInput.value = ""
		}
	})

	chatEnterBtn.addEventListener("click", event => {
		space.push("new_msg", { body: chatInput.value })
		chatInput.value = ""

	})


	function join_space(interval) {
		space = socket.channel(`space:${interval}`)
		space.join()
			.receive("ok", resp => { console.log("Joined space!", resp) })
			.receive("error", resp => { console.log("Unable to join space", resp) })

		let presence = new Presence(space)
		presence.onSync(() => renderOnlineUsers(presence))

		space.onError(() => console.log("there was an error!"))
		space.onClose(() => console.log("the channel has gone away gracefully"))

		space.on("new_interval", payload => { new_interval(payload) })
		space.on("new_url", payload => { new_url(payload) })
		space.on("new_msg", payload => { new_message(payload) })
		space.on("countdown_tick", payload => { countdown_tick(payload) })

	}

	function change_room(interval) {
		console.log("chat about to leave is..")
		console.log(space)
		space.leave()
		messagesContainer.innerHTML = ""
		join_space(interval)
	}

	const onlineUserTemplate = function (user) {
		var typingIndicator = ''
		// if (user.typing) {
		// 	typingIndicator = 'typing'
		// }

		return `<div id="online-user-${user.user_id}">
		<strong class="${typingIndicator}">${user.username}</strong> 
	  </div>`
	}

	function renderOnlineUsers(presence) {
		console.log("IN RENDER USERS")

		let onlineUsers = presence.list((id, { metas: [user, ...rest] }) => {
			return onlineUserTemplate(user)
		}).join("")

		document.querySelector("#online-users").innerHTML = onlineUsers
	}

	function countdown_tick(payload) {
		countdownContainer.innerHTML = payload.time
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
		explanationContainer.innerHTML = payload.explanation
	}

	function new_message(payload) {
		var today = new Date()
		var time = today.getHours() + ":" + today.getMinutes()
		let messageItem = document.createElement("p")
		messageItem.innerText = `${payload.username}(${time}) - ${payload.body}`
		messagesContainer.appendChild(messageItem)

		const targetNode = document.querySelector("#messages")
		targetNode.scrollTop = targetNode.scrollHeight
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



