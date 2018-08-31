![FME AR](https://is3-ssl.mzstatic.com/image/thumb/Purple118/v4/31/9c/c7/319cc748-5ac6-2d91-8b1a-afdc7e3e164e/AppIcon-1x_U007emarketing-0-0-GLES2_U002c0-512MB-sRGB-0-0-0-85-220-0-0-0-6.png/246x0w.jpg)

# FME AR

This repository contains the source code of the FME AR mobile app for iOS.

## Description
The FME AR writer introduced in FME 2018.0 can create 3D models in the custom FME AR format with a file extension .fmear. This iOS app can open those .fmear files from cloud storages such as iCloud Drive and Dropbox, and display the models in augmented reality. Using FME Workbench, 3D models from many different formats can be converted to the FME AR format. Once the .fmear files are uploaded to a supported cloud storage, the app will list the files, and the user can select a file to view in augmented reality.

This app is built on the new iOS 11 augmented reality framework called ARKit. It allows people to easily create unparalleled augmented reality experiences for iPhone and iPad. It has an accurate tracking of device movement. It can analyze the scene presented by the camera view and find horizontal and vertical planes in the real world. It can place and track virtual objects on the plane with a high degree of accuracy without additional calibration.

## Requirements
The augmented reality feature requires a lot of computational power, so it requires iOS devices with an Apple A9, A10, and newer processors. The following devices are able to run the app:

* iPhone 6s and 6s Plus
* iPhone 7 and 7 Plus
* iPhone 8 and 8 Plus
* iPhone X
* iPhone SE
* iPad Pro (9.7, 10.5 and 12.9)
* iPad (2017)

For details and feedback, please visit: https://blog.safe.com/2017/09/augmented-reality-for-ios-making-3d-models-for-arkit-with-fme/

## Limitation
We have tested the app with iCloud Drive, Dropbox, and OneDrive. The app currently doesn't recognize the .fmear files in the current version of Google Drive on iOS 11.

## Instructions
- Cloud Storage Access: You will need to install the specific cloud storage apps such as Dropbox and OneDrive and enable them in the app before you can see and select a .fmear file.
- Surface Detection: A surface with some textures is better than a surface with a solid colour. You may need to slightly tilt and move your device so that it can detect the surface. When a surface is detected, a yellow square will be shown.

## Licenses
* [FME AR](https://github.com/safesoftware/fme-ar-ios/blob/master/LICENSE)
* [Apple](https://github.com/safesoftware/fme-ar-ios/blob/master/LICENSE-APPLE)
* [SSZipArchive](https://github.com/safesoftware/fme-ar-ios/blob/master/FMEAR/3rd/SSZipArchive/LICENSE)
* [Minizip](http://www.zlib.net/zlib_license.html)