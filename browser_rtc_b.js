var localConnection = new RTCPeerConnection({
  iceServers: [{ url: "stun:stun.l.google.com:19302" }],
});

localConnection.onicecandidate = (e) => {
  console.log(" NEW ice candidnat!! on localconnection reprinting SDP ");
  console.log(JSON.stringify(localConnection.localDescription));
};

localConnection.ondatachannel = (e) => {
  const receiveChannel = e.channel;
  receiveChannel.onmessage = (e) =>
    console.log("messsage received!!!" + e.data);
  receiveChannel.onopen = (e) => console.log("open!!!!");
  receiveChannel.onclose = (e) => console.log("closed!!!!!!");
  localConnection.channel = receiveChannel;
};

localConnection.setRemoteDescription(offer).then((a) => console.log("done"));

//create answer
await localConnection
  .createAnswer()
  .then((a) => localConnection.setLocalDescription(a))
  .then((a) => console.log(JSON.stringify(localConnection.localDescription)));



  