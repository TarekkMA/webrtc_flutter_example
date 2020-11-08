var localConnection = new RTCPeerConnection({
  iceServers: [{ url: "stun:stun.l.google.com:19302" }],
});

localConnection.onicecandidate = (e) => {
  console.log(" NEW ice candidnat!! on localconnection reprinting SDP ");
  console.log(JSON.stringify(localConnection.localDescription));
};

const sendChannel = localConnection.createDataChannel("sendChannel");
sendChannel.onmessage = (e) => console.log("messsage received!!!" + e.data);
sendChannel.onopen = (e) => console.log("open!!!!");
sendChannel.onclose = (e) => console.log("closed!!!!!!");

localConnection
  .createOffer()
  .then((o) => localConnection.setLocalDescription(o));

//////////

localConnection.setRemoteDescription(answer).then((a) => console.log("done"));
