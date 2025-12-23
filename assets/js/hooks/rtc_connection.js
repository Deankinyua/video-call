let RtcConnectionHooks = {};

RtcConnectionHooks.RtcConnection = {
  mounted() {
    // * Grab all the video elements
    this.localVideoEl = document.querySelector("#local-video");
    this.remoteVideoEl = document.querySelector("#remote-video");

    this.localStream; //a var to hold the local video stream
    this.remoteStream; //a var to hold the remote video stream
    this.peerConnection; //the peerConnection that the two clients use to talk
    this.didIOffer = false;

    // * The STUN servers
    this.peerConfiguration = {
      iceServers: [
        {
          urls: [
            "stun:stun.l.google.com:19302",
            "stun:stun1.l.google.com:19302",
          ],
        },
      ],
    };

    this.init();
  },

  async init() {
    await this.fetchUserMedia();

    //peerConnection is all set with our STUN servers sent over
    await this.createPeerConnection();

    //create offer time!
    try {
      console.log("Creating offer...");
      const offer = await this.peerConnection.createOffer();
      console.log(offer.type); // Should be 'offer'
      // setLocalDescription is called so that the 2 peers eventually agree on a configuration
      this.peerConnection.setLocalDescription(offer);
      this.didIOffer = true;
      this.pushEvent("new-offer", { offer: offer }); //send offer to signalingServer
    } catch (err) {
      console.log(err);
    }
  },

  fetchUserMedia() {
    return new Promise(async (resolve, reject) => {
      try {
        // getUserMedia returns a promise so we have to handle it with await to get the stream
        const stream = await navigator.mediaDevices.getUserMedia({
          video: true,
          // audio: true,
        });

        // * so that you can see yourself on the screen
        this.localVideoEl.srcObject = stream;
        this.localStream = stream;
        resolve();
      } catch (err) {
        console.log(err);
        reject();
      }
    });
  },

  createPeerConnection(offerObj) {
    return new Promise(async (resolve, reject) => {
      //RTCPeerConnection is the thing that creates the connection
      //we can pass a config object, and that config object can contain STUN/ICE servers
      //which will fetch us ICE candidates
      let pc = new RTCPeerConnection(this.peerConfiguration);
      // set the remote stream to a new empty mediaStream
      this.remoteStream = new MediaStream();
      this.remoteVideoEl.srcObject = this.remoteStream;

      // stream.getTracks returns a sequence/array of tracks
      this.localStream.getTracks().forEach((track) => {
        //add localtracks so that they can be sent once the connection is established
        pc.addTrack(track, this.localStream);
      });

      pc.addEventListener("signalingstatechange", (event) => {
        console.log(pc.signalingState);
      });

      // to check if icecandidates were generated
      pc.addEventListener("icecandidate", (e) => {
        console.log("........Ice candidate found!......");
        console.log(e.candidate);
        if (e.candidate) {
          // This is how we are going propagate ice candidates to the other peer
          // if didIOffer is true, then this ice candidates belong to the offerer, else they belong to the answerer
          //   socket.emit("sendIceCandidateToSignalingServer", {
          //     iceCandidate: e.candidate,
          //     iceUserName: userName,
          //     didIOffer,
          //   });
        }
      });

      // This will be called when tracks added from the remote side
      pc.addEventListener("track", (e) => {
        console.log("Got a track from the other peer!! How excting");
        console.log(e.streams);
        e.streams[0].getTracks().forEach((track) => {
          this.remoteStream.addTrack(track);
        });
      });

      this.peerConnection = pc;

      if (offerObj) {
        //this won't be set when called from call();
        //will be set when we call from answerOffer()
        await this.peerConnection.setRemoteDescription(offerObj.offer);
        // console.log(peerConnection.signalingState) //should be have-remote-offer, because client2 has setRemoteDesc on the offer
      }
      resolve();
    });
  },
};

export default RtcConnectionHooks;
