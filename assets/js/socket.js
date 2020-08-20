// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "assets/js/app.js".

// To use Phoenix channels, the first step is to import Socket,
// and connect at the socket path in "lib/web/endpoint.ex".
//
// Pass the token on params as below. Or remove it
// from the params if you are not using authentication.
import { Socket } from "phoenix"

let socket = new Socket("/socket", { params: { token: window.userToken } })

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
socket.connect()

// Image channel 
let imgContainer = document.querySelector("#url")
let intervalContainer = document.querySelector("#interval")
let intervalInput = document.querySelector("#interval-input")
let killButton = document.querySelector("#kill")

// chat channel 
let chatInput = document.querySelector("#chat-input")
let messagesContainer = document.querySelector("#messages")


// Join channel for image server:
let client_id = uuidv4();
let channel = socket.channel(`room:${client_id}`, { client_id })

let join_result = channel.join()
	.receive("ok", resp => { console.log("JOINED", resp) })
	.receive("error", resp => { console.log("Unable to join", resp) })

if (join_result.channel.state == "joining") {
	// if channel join successful, create unique genserver/Agent instance 
	channel.push("create_server", { client_id: client_id })
		.receive("ok", payload => console.log("phoenix replied:", payload))
	// join chat for default interval

}

// Receive new incoming img url message
channel.on("new_url", payload => {

	console.log("new URL!")

	imgContainer.innerHTML = ''
	let imgItem = document.createElement("img")
	imgItem.src = payload.url
	imgItem.classList.add("space-img");
	imgContainer.appendChild(imgItem)

})

// submit new outgoing interval 
intervalInput.addEventListener("keypress", event => {
	if (event.key === 'Enter') {
		console.log("Sending new interval....")
		channel.push("change_interval", { interval: intervalInput.value, client_id: client_id })
		intervalInput.value = ""
	}


})

// Kill server process 
killButton.addEventListener("click", event => {
	console.log("clicked kill")
	channel.push("kill", { client_id: client_id })


})

// new incombing msg containing new interval 
channel.on("new_interval", payload => {
	console.log("New Interval Receieved")
	intervalContainer.innerHTML = payload.interval

	console.log(payload.interval)

	// disconnect from current chat 

	// join new chat 
	// var chat = socket.channel(`chat:${payload.interval}`)
	// chat.join()
	// 	.receive("ok", resp => { console.log("Join chat!", resp) })
	// 	.receive("error", resp => { console.log("Unable to join chat", resp) })

	// chat.on("new_msg", payload => {
	// 	let messageItem = document.createElement("p")
	// 	messageItem.innerText = `[${Date()}] ${payload.body}`
	// 	messagesContainer.appendChild(messageItem)
	// })

	// chatInput.addEventListener("keypress", event => {
	// 	if (event.key === 'Enter') {
	// 		chat.push("new_msg", { body: chatInput.value })
	// 		chatInput.value = ""
	// 	}
	// 	else if (event.key === '8') {
	// 		chat.leave().receive("ok", () => alert("left!"))
	// 		chatInput.value = ""
	// 	}
	// })



})


// chat stuff-------

function join_chat(interval) {

	// var chat = socket.channel(`chat:${interval}`, { interval })
	// chat.join()
	// 	.receive("ok", resp => { console.log("Join chat!", resp) })
	// 	.receive("error", resp => { console.log("Unable to join chat", resp) })

	// chat.on("new_msg", payload => {
	// 	let messageItem = document.createElement("p")
	// 	messageItem.innerText = `[${Date()}] ${payload.body}`
	// 	messagesContainer.appendChild(messageItem)
	// })

	// chatInput.addEventListener("keypress", event => {
	// 	if (event.key === 'Enter') {
	// 		chat.push("new_msg", { body: chatInput.value })
	// 		chatInput.value = ""
	// 	}
	// })
}




export default socket




function uuidv4() {
	return ([1e7] + -1e3 + -4e3 + -8e3 + -1e11).replace(/[018]/g, c =>
		(c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> c / 4).toString(16)
	);
}
