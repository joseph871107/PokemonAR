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

1. 到 [Meta for Developers](https://developers.facebook.com/apps/?show_reminder=true) 中登入並右上角點選建立應用程式
2. 應用程式類型需選擇`無`
3. 填寫應用程式顯示名稱 電子郵件地址以及選取商業帳號(若沒有則無)並建立應用程式
4. 如有需要確認密碼請輸入

**進入專案頁後開始設定登入的權限**

5. 進到主控台選擇`Facebook登入-設定`
6. 平台選擇iOS
7. 開發環境選擇預設`SDK: Swift Package Manager`就好並繼續
8. 跳回主控台並在左手邊Sidebar選擇`Facebook登入-設定`
9. 將`嵌入的瀏覽器 OAuth 登入`開啟
10. 將`從裝置登入`開啟
11. 保留此頁面，接續Firebase設定

## Firebase

### Setup

1. 進入[Firebase後台](https://console.firebase.google.com/u/0/)點選新增專案
2. 輸入專案名稱
3. Google Analytics可以開可以不開
4. (設定 Google Analytics) 選擇帳戶
5. 建立專案

**進入專案頁後開始設定各個服務的權限**

#### Authentication
6. 左邊Sidebar點選`Authentication`，開始使用
7. 新增電子郵件/密碼上方toggle啟用並儲存
8. 再次點選新增供應商，點選Facebook並上方toggle啟用
9. 將上面Meta for Developer開通步驟取得的`應用程式ID`以及`應用程式密鑰`輸入進表單中
    - `應用程式ID`為Meta專案主控台左上方的`應用程式編號`
    - `應用程式金鑰`在Meta專案主控台左手邊Sidebar點選`設定-基本資料`後的`應用程式密鑰`點選顯示
10. 下方連結複製到Meta for Developer剛剛保留頁面中的`有效的 OAuth 重新導向 URI`

#### Firestore Database
11. 左邊Sidebar點選`Firestore Database`，建立資料庫
12. Popup menu選擇`以測試模式啟動`並繼續
13. 資料庫位置可以選進一點的`asia-east`理論上應該會比較快，點選啟用
14. 進入資料庫後點選上面規則，並把規則替換成下面並發布

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
15. 左邊Sidebar點選`Storage`
16. 進到上方Rules並把規則替換成下面並發布

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

**利用剛才所建立的各種資訊複製到此repo中的各檔案**

17. 用Xcode開啟repo中的`PokemonAR.xcworkspace`
18. 回到Firebase中的`專案總覽`
19. 中間新增應用程式選擇iOS+
20. 如果有將Project重新Signing到自己的Apple ID，可能Bundle Identifier也有改變，將設定好的Bundle Identifier複製進剛剛頁面中`Apple軟體包ID`
21. 應用程式暱稱建議填入。
22. 完成後點選`註冊應用程式`
23. 點選`下載 GoogleService-Info.plist`並拉近project複製過去
24. 在Xcode專案中右鍵`New File`尋找`Property List`取名叫`Info.plist`
25. 從 `Project -> Targets -> Info -> Custom iOS Target Properties` 將現有的所有設定全部複製到新的 `Info.plist`
26. 新增四個設定
    - URL types [Array]
      - Item 0 [Dictionary]
        - URL Schemes [Array]
          - Item 0 [String] 第一個變數
    
    - FacebookAppID [String] 第二個變數
    - FacebookClientToken [String] 第三個變數
    - FacebookDisplayName [String] 第四個變數
27. 回到Meta for Developers將上方`應用程式編號`複製貼上第一個變數前面加上`fb`，例如應用程式編號為`977213666286434`，需填入`fb977213666286434`，接下來直接將原始數值填入第二個變數
28. 再來回到頁面到左手邊Sidebar選擇`設定-進階`，將`用戶端權杖`複製到第三個變數
29. 再來回到頁面到左手邊Sidebar選擇`設定-基本資料`，將`顯示名稱`複製到第四個變數
30. 回到Xcode到`Solution -> Open target -> Build phases > Copy Bundle Resources`將`Info.plist`移除掉
31. 開始編譯