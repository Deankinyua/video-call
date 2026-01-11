let RtcConnectionHooks = {};

RtcConnectionHooks.RtcConnection = {
  mounted() {
    // * Grab all the video elements
    this.localVideoEl = document.querySelector("#local-video");
    this.remoteVideoEl = document.querySelector("#remote-video");

    this.localStream;
    this.remoteStream;
    this.peerConnection;
    this.didIOffer = false;

    // * The STUN servers
    this.peerConfiguration = {
      iceServers: [
        {
          urls: "stun:157.173.115.229:3478",
        },
        {
          urls: "turn:157.173.115.229:3478",
          username: "dean",
          credential: "cobraKinyua",
        },
      ],
    };

    this.init();

    this.checkTurn();

    this.handleEvent("create_offer", () => {
      this.createOffer();
    });

    this.handleEvent("answer", ({ offer_obj }) => {
      this.answerOffer(offer_obj);
    });

    this.handleEvent("offerer_ice_candidates", ({ candidates }) => {
      candidates.forEach((c) => {
        this.peerConnection.addIceCandidate(c);
      });
    });

    this.handleEvent("add_ice_candidate_from_other_peer", ({ candidate }) => {
      this.peerConnection.addIceCandidate(candidate);
    });

    this.handleEvent("add_answer", ({ answer }) => {
      this.addAnswer(answer);
    });

    this.handleEvent("end_call", () => {
      this.peerConnection.close();
      this.remoteVideoEl.srcObject = new MediaStream();
    });
  },

  checkTURNServer(turnConfig, timeout = 5000) {
    return new Promise(async (resolve, reject) => {
      const pc = new RTCPeerConnection(turnConfig);
      let promiseResolved = false;
      // if no TURN relay candidate is found within the 5 seconds, assume the TURN server
      // is not working and resolve with false
      setTimeout(() => {
        if (promiseResolved) return;
        promiseResolved = true;
        resolve(false);
      }, timeout);
      // Create a bogus data channel
      pc.createDataChannel("");
      // Listen for candidates
      pc.onicecandidate = (ice) => {
        if (promiseResolved || ice === null || ice.candidate === null) return;
        console.log(ice.candidate.type);
        if (ice.candidate.type === "relay") {
          promiseResolved = true;
          resolve(true);
        }
      };
      // Create offer and set local description
      const offer = await pc.createOffer();
      await pc.setLocalDescription(offer);
    });
  },

  async init() {
    await this.fetchUserMedia();
  },

  async checkTurn() {
    let isOnline = await this.checkTURNServer(this.peerConfiguration);
    console.log("Is the turn server online? " + isOnline);
  },

  async createOffer() {
    await this.createPeerConnection();

    try {
      const offer = await this.peerConnection.createOffer();
      // setLocalDescription is called so that the 2 peers eventually agree on a configuration
      await this.peerConnection.setLocalDescription(offer);
      this.didIOffer = true;
      this.pushEvent("new_offer", { offer: offer }); //send offer to signalingServer
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
          audio: {
            volume: 1.0,
            channelCount: 1,
            autoGainControl: false,
            googAutoGainControl: false,
            echoCancellation: false,
            noiseSuppression: false,
          },
        });

        this.localVideoEl.srcObject = stream;
        this.localStream = stream;
        resolve();
      } catch (err) {
        console.log(err);
        reject();
      }
    });
  },

  async answerOffer(offerObj) {
    await this.fetchUserMedia();
    await this.createPeerConnection(offerObj);
    const answer = await this.peerConnection.createAnswer();

    //* set answer as the localDescription of the answerer
    await this.peerConnection.setLocalDescription(answer);

    this.pushEvent("add_offerer_ice_candidates_to_answerer", {
      offer_obj_id: offerObj.offerer,
    });

    this.pushEvent("set_remote_description_of_offerer", {
      answer: answer,
      offerer: offerObj.offerer,
    });
  },

  async addAnswer(answer) {
    //* set answer as remote description of the offerer
    await this.peerConnection.setRemoteDescription(answer);
    // once the connection is stable, remove object from Signalling server

    // if (this.peerConnection.signalingState === "stable") {
    //   this.pushEvent("clear_offer_object", {});
    // }

    // and that's about it!!
  },

  createPeerConnection(offerObj) {
    return new Promise(async (resolve, reject) => {
      //note: RTCPeerConnection is the thing that creates the connection
      //note: We need to pass the iceCandidates while initializing the peerConnection

      let pc = new RTCPeerConnection(this.peerConfiguration);
      this.remoteStream = new MediaStream();
      this.remoteVideoEl.srcObject = this.remoteStream;

      // stream.getTracks returns a sequence/array of tracks
      this.localStream.getTracks().forEach((track) => {
        //add localtracks so that they can be sent once the connection is established
        pc.addTrack(track, this.localStream);
      });

      pc.addEventListener("connectionstatechange", () => {
        if (pc.connectionState === "disconnected") {
          this.pushEvent("peer_connection_disconnected", {});
        }

        if (pc.connectionState === "connected") {
          this.pushEvent("peer_connection_connected", {});
        }

        console.log("Connection State:", pc.connectionState);
      });

      // check if icecandidates were generated
      pc.addEventListener("icecandidate", (e) => {
        if (e.candidate) {
          this.pushEvent("send_ice_candidate_to_signalling_server", {
            did_i_offer: this.didIOffer,
            ice_candidate: e.candidate,
          });
        }
      });

      // This will be called when tracks are added from the remote side
      pc.addEventListener("track", (e) => {
        e.streams[0].getTracks().forEach((track) => {
          this.remoteStream.addTrack(track);
        });
      });

      this.peerConnection = pc;

      if (offerObj) {
        // * This will set the remoteDescription of CLIENT2 as the offer
        await this.peerConnection.setRemoteDescription(offerObj.offer);
        console.log(this.peerConnection.signalingState); //should be have-remote-offer, because answerer has setRemoteDesc on the offer
      }
      resolve();
    });
  },
};

export default RtcConnectionHooks;
