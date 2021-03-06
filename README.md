# Pokemon AR
- Tensorflow Lite iOS Detection Application
- NTUT CSIE 110-2 iOS final project


**iOS Versions Supported:** iOS 14.0 and above.
**Xcode Version Required:** 13.0 and above

## Overview

This is a Pokemon Game emdeded with camera app that continuously detects the objects (bounding boxes and classes) in the frames seen by your device's back camera, using a quantized [MobileNet SSD](https://github.com/tensorflow/models/tree/master/research/object_detection) model trained on the [COCO dataset](http://cocodataset.org/). These instructions walk you through building and running the demo on an iOS device.

The model files are downloaded via scripts in Xcode when you build and run. You don't need to do any steps to download TFLite models into the project explicitly.

## Detection part
### Prerequisites

* You must have Xcode installed

* You must have a valid Apple Developer ID

* The demo app requires a camera and must be executed on a real iOS device. You can build it and run with the iPhone Simulator but the app raises a camera not found exception.

* You don't need to build the entire TensorFlow library to run the demo, it uses CocoaPods to download the TensorFlow Lite library.

* You'll also need the Xcode command-line tools:
 ```xcode-select --install```
 If this is a new install, you will need to run the Xcode application once to agree to the license before continuing.
### Building the iOS Demo App

1. Install CocoaPods if you don't have it.
```sudo gem install cocoapods```

2. Install the pod to generate the workspace file:
```cd PokemonAR/```
```pod install```
  If you have installed this pod before and that command doesn't work, try
```pod update```
At the end of this step you should have a file called ```PokemonAR.xcworkspace```

3. Open **PokemonAR.xcworkspace** in Xcode.

4. Please change the bundle identifier to a unique identifier and select your development team in **'General->Signing'** before building the application if you are using an iOS device.

5. Build and run the app in Xcode.
You'll have to grant permissions for the app to use the device's camera. Point the camera at various objects and enjoy seeing how the model classifies things!

### Model Used

This app uses a MobileNet SSD model trained on [COCO dataset](http://cocodataset.org/). The input image size required is 300 X 300 X 3. You can download the model [here](https://storage.googleapis.com/download.tensorflow.org/models/tflite/coco_ssd_mobilenet_v1_1.0_quant_2018_06_29.zip). You can find more information on the research on object detection [here](https://github.com/tensorflow/models/tree/master/research/object_detection).

## Facebook Authentication

### Setup

1. ??? [Meta for Developers](https://developers.facebook.com/apps/?show_reminder=true) ?????????????????????????????????????????????
2. ???????????????????????????`???`
3. ?????????????????????????????? ??????????????????????????????????????????(???????????????)?????????????????????
4. ?????????????????????????????????

**?????????????????????????????????????????????**

5. ?????????????????????`Facebook??????-??????`
6. ????????????iOS
7. ????????????????????????`SDK: Swift Package Manager`???????????????
8. ??????????????????????????????Sidebar??????`Facebook??????-??????`
9. ???`?????????????????? OAuth ??????`??????
10. ???`???????????????`??????
11. ????????????????????????Firebase??????

## Firebase

### Setup

1. ??????[Firebase??????](https://console.firebase.google.com/u/0/)??????????????????
2. ??????????????????
3. Google Analytics?????????????????????
4. (?????? Google Analytics) ????????????
5. ????????????

**???????????????????????????????????????????????????**

#### Authentication
6. ??????Sidebar??????`Authentication`???????????????
7. ??????????????????/????????????toggle???????????????
8. ????????????????????????????????????Facebook?????????toggle??????
9. ?????????Meta for Developer?????????????????????`????????????ID`??????`??????????????????`??????????????????
    - `????????????ID`???Meta???????????????????????????`??????????????????`
    - `??????????????????`???Meta????????????????????????Sidebar??????`??????-????????????`??????`??????????????????`????????????
10. ?????????????????????Meta for Developer????????????????????????`????????? OAuth ???????????? URI`

#### Firestore Database
11. ??????Sidebar??????`Firestore Database`??????????????????
12. Popup menu??????`?????????????????????`?????????
13. ????????????????????????????????????`asia-east`??????????????????????????????????????????
14. ???????????????????????????????????????????????????????????????????????????

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

#### Storage
15. ??????Sidebar??????`Storage`
16. ????????????Rules????????????????????????????????????

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if true;
    }
  }
}
```

## Swift

**????????????????????????????????????????????????repo???????????????**

17. ???Xcode??????repo??????`PokemonAR.xcworkspace`
18. ??????Firebase??????`????????????`
19. ??????????????????????????????iOS+
20. ????????????Project??????Signing????????????Apple ID?????????Bundle Identifier??????????????????????????????Bundle Identifier????????????????????????`Apple?????????ID`
21. ?????????????????????????????????
22. ???????????????`??????????????????`
23. ??????`?????? GoogleService-Info.plist`?????????project????????????
24. ???Xcode???????????????`New File`??????`Property List`?????????`Info.plist`
25. ??? `Project -> Targets -> Info -> Custom iOS Target Properties` ????????????????????????????????????????????? `Info.plist`
26. ??????????????????
    - URL types [Array]
      - Item 0 [Dictionary]
        - URL Schemes [Array]
          - Item 0 [String] ???????????????
    
    - FacebookAppID [String] ???????????????
    - FacebookClientToken [String] ???????????????
    - FacebookDisplayName [String] ???????????????
27. ??????Meta for Developers?????????`??????????????????`???????????????????????????????????????`fb`??????????????????????????????`977213666286434`????????????`fb977213666286434`??????????????????????????????????????????????????????
28. ??????????????????????????????Sidebar??????`??????-??????`??????`???????????????`????????????????????????
29. ??????????????????????????????Sidebar??????`??????-????????????`??????`????????????`????????????????????????
30. ??????Xcode???`Solution -> Open target -> Build phases > Copy Bundle Resources`???`Info.plist`?????????
31. ????????????