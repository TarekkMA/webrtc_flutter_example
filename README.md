# webrtc_flutter_test

This is a simple flutter text chat application using `flutter_webrtc`.

[![Demo](https://j.gifs.com/jZDWvv.gif)](https://www.youtube.com/watch?v=e2Vf27yLQaE)

## How to use this demo

This demo does only have the webrtc code with no signaling logic, the signaling should be done via other means. Click on the gif above demonstrating the following steps.

- First **A** click on offer button to create an offer sdp.
- **A** should signal the offer sdp via WhatsApp for example to **B**
- **B** should open the application and click on answer button to create an answer sdp.
- **B** should signal the answer sdp back to **A**
- **A** should click on set remote and use the answer sdp he got from **B**

## Resources

- [[YouTube] WebRTC Crash Course](https://www.youtube.com/watch?v=FExZvpVvYxA)
- [flutter-webrtc/flutter-webrtc-demo](https://github.com/flutter-webrtc/flutter-webrtc-demo)
