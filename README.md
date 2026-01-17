# Demo

**Sign up** at [Easy Video Call](https://easy-video-call.fly.dev/)

https://github.com/user-attachments/assets/38bd9b91-d94b-4894-a068-f0ca5036652d

# Easy Video Call

A **video calling** application made with **Phoenix/Elixir** that utilizes **WebRTC**.

The `rtc_connection.js` file contains all the JavaScript for establishing the PeerConnection.

Signalling has been implemented using Elixir GenServer and PubSub for sending messages.

# Setup

- The app will run fine as long as the 2 peers are on the **same local network**.
- To connect across networks, provision a **VPS**, install [coturn](https://github.com/coturn/coturn) on it, then add your **credentials** in the **ICE** configuration object:

```javascript
this.peerConfiguration = {
  iceServers: [
    {
      urls: "stun:<your_ip_address>:3478",
    },
    {
      urls: "turn:<your_ip_address>:3478",
      username: "<username>",
      credential: "<password>",
    },
  ],
};
```

To start your Phoenix server:

- Run `mix setup` to install and setup dependencies
- Start Phoenix endpoint with ngrok using this command`make iex_server`
- Ngrok will provide the URL in the terminal so open that with any browser
