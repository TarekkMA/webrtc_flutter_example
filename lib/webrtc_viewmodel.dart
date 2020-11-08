import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:mobx/mobx.dart';
part 'webrtc_viewmodel.g.dart';

Map<String, dynamic> _connectionConfiguration = {
  'iceServers': [
    {'url': 'stun:stun.l.google.com:19302'},
  ]
};

const _offerAnswerConstraints = {
  'mandatory': {
    'OfferToReceiveAudio': false,
    'OfferToReceiveVideo': false,
  },
  'optional': [],
};

class WebRtcViewModel = _WebRtcViewModelBase with _$WebRtcViewModel;

abstract class _WebRtcViewModelBase with Store {
  RTCDataChannel _dataChannel;
  RTCPeerConnection _connection;
  RTCSessionDescription _sdp;

  @observable
  ObservableList<Message> messages = ObservableList.of([]);

  @action
  Future<void> offerConnection() async {
    _connection = await _createPeerConnection();
    await _createDataChannel();
    RTCSessionDescription offer =
        await _connection.createOffer(_offerAnswerConstraints);
    await _connection.setLocalDescription(offer);
    _sdpChanged();
    messages.add(Message.fromSystem("Created offer"));
  }

  @action
  Future<void> answerConnection(RTCSessionDescription offer) async {
    _connection = await _createPeerConnection();
    await _connection.setRemoteDescription(offer);
    final answer = await _connection.createAnswer(_offerAnswerConstraints);
    await _connection.setLocalDescription(answer);
    _sdpChanged();
    messages.add(Message.fromSystem("Created Answer"));
  }

  @action
  Future<void> acceptAnswer(RTCSessionDescription answer) async {
    await _connection.setRemoteDescription(answer);
    messages.add(Message.fromSystem("Answer Accepted"));
  }

  @action
  Future<void> sendMessage(String message) async {
    await _dataChannel.send(RTCDataChannelMessage(message));
    messages.add(Message.fromUser("ME", message));
  }

  Future<RTCPeerConnection> _createPeerConnection() async {
    final con = await createPeerConnection(_connectionConfiguration);
    con.onIceCandidate = (candidate) {
      messages.add(Message.fromSystem("New ICE candidate"));
      _sdpChanged();
    };
    con.onDataChannel = (channel) {
      messages.add(Message.fromSystem("Recived data channel"));
      _addDataChannel(channel);
    };
    return con;
  }

  void _sdpChanged() async {
    _sdp = await _connection.getLocalDescription();
    Clipboard.setData(ClipboardData(text: json.encode(_sdp.toMap())));
    messages.add(
        Message.fromSystem("${_sdp.type} SDP is coppied to the clipboard"));
  }

  Future<void> _createDataChannel() async {
    RTCDataChannelInit dataChannelDict = new RTCDataChannelInit();
    RTCDataChannel channel =
        await _connection.createDataChannel("textchat-chan", dataChannelDict);
    messages.add(Message.fromSystem("Created data channel"));
    _addDataChannel(channel);
  }

  void _addDataChannel(RTCDataChannel channel) {
    _dataChannel = channel;
    _dataChannel.onMessage = (data) {
      messages.add(Message.fromUser("OTHER", data.text));
    };
    _dataChannel.onDataChannelState = (state) {
      messages.add(Message.fromSystem("Data channel state: $state"));
    };
  }
}

@immutable
class Message extends Equatable {
  final String sender;
  final bool isSystem;
  final String message;

  Message(this.sender, this.isSystem, this.message);
  Message.fromUser(this.sender, this.message) : isSystem = false;
  Message.fromSystem(this.message)
      : this.sender = "System",
        isSystem = true;

  @override
  List<Object> get props => [sender, isSystem, message];
}
