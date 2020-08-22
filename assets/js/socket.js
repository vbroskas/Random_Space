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


// START Image/Interval channel & elements-------------------------
let imgContainer = document.querySelector("#url")
let intervalContainer = document.querySelector("#interval")
let intervalInput = document.querySelector("#interval-input")
let killButton = document.querySelector("#kill")

// create mock/fake uuid for client 
let client_id = uuidv4()
let channel = socket.channel(`room:${client_id}`)
let channel_join_result = channel.join()
	.receive("ok", resp => { console.log("JOINED", resp) })
	.receive("error", resp => { console.log("Unable to join", resp) })

if (channel_join_result.channel.state == "joining") {
	// if channel join successful, create unique genserver/Agent instance 
	channel.push("create_server", { client_id: client_id })
		.receive("ok", payload => console.log("phoenix replied:", payload))

}
// Receive new incoming img url message
channel.on("new_url", payload => {

	imgContainer.innerHTML = ''
	let imgItem = document.createElement("img")
	imgItem.src = payload.url
	imgItem.classList.add("space-img")
	imgContainer.appendChild(imgItem)

})
// submit new outgoing interval & join chat for that interval
intervalInput.addEventListener("keypress", event => {
	if (event.key === 'Enter') {
		let interval = intervalInput.value
		channel.push("change_interval", { interval: interval, client_id: client_id })
		intervalInput.value = ""
		// join new chat room 
		change_chat(interval, client_id)
	}

})
// Kill server process 
killButton.addEventListener("click", event => {
	channel.push("kill", { client_id: client_id })
})

// new incombing msg containing new interval 
channel.on("new_interval", payload => {
	console.log("New Interval Receieved")
	intervalContainer.innerHTML = payload.interval
	intervalInput.value = ""


})
// END Image/Interval channel & elements-------------------------





// START chat channel & elements-------------------------
let chatInput = document.querySelector("#chat-input")
let messagesContainer = document.querySelector("#messages")

chatInput.addEventListener("keypress", event => {

	if (event.key === 'Enter') {
		console.log("ENTER")
		chat.push("new_msg", { body: chatInput.value })
		chatInput.value = ""
	}

})

// initialize client to join room 15 (default interval)
let chat = socket.channel("chat:15", { client: client_id })
chat.join()
	.receive("ok", resp => { console.log("Joined chat!", resp) })
	.receive("error", resp => { console.log("Unable to join chat", resp) })

chat.on("new_msg", payload => { new_message(payload) })



function change_chat(new_room, client_id) {

	// leave chat currently connected to 
	chat.leave()
	messagesContainer.innerHTML = ""
	// connect to new chat room based on interval 
	chat = socket.channel(`chat:${new_room}`, { client: client_id })
	chat.join()
		.receive("ok", resp => { console.log("Joined chat!", resp) })
		.receive("error", resp => { console.log("Unable to join chat", resp) })

	// on new incoming msg 
	chat.on("new_msg", payload => { new_message(payload) })


}

// append new incoming chat message to chat window 
function new_message(payload) {
	let messageItem = document.createElement("p")
	messageItem.innerText = `[${Date()}] ${payload.body}`
	messagesContainer.appendChild(messageItem)
}

// create fake uuid 
function uuidv4() {
	return ([1e7] + -1e3 + -4e3 + -8e3 + -1e11).replace(/[018]/g, c =>
		(c ^ crypto.getRandomValues(new Uint8Array(1))[0] & 15 >> c / 4).toString(16)
	);
}



export default socket



