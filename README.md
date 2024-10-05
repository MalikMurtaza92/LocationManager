# Location Manager
Location manager is a customer location class build on top of Core Location class CLLocationManager. It is easy to implemented in your project because it's abstract it's complexity.
## Content
- [Requirement](#requirement)
- [Installation](#installation)
- [Usage](#usage)
- [Credits](#credits)

## Requirement
- iOS 13.0 or later
- XCode 11.0 or later
- Swift 5.0 or later

## Installation
There are two way to use this location manager class into your code base
- Add code snippet into your xcode.
- Manually add location manager class into your code.

### Code snippet
Download or clone the project from github repository and copy the LocationManager.codesnippet file and paste it into following directory 
```swift
/Users/[USERNAME]/Library/Developer/Xcode/UserData/CodeSnippets/
```
### Manually use code
Download or clone the project from github repo and copy LocationManager.swift file or it's code and paste it inside your codebase.

## Usage
### Quick start
Create instance for location manager
```swift
var locationManager: LocationManagerProtocol?
locationManager = LocationManager()
```
or 
```swift
let locationManager = LocationManager()
```

Set custom distance filter value
```swift
locationManager?.distanceFilter = 10
```

> Default value of distance filter is 100

Use authorization error handle, suppose if you want to add any alert or implementation accordingly.
```swift
locationManager?.authorizationErrorHandler = { [weak self] status in
    guard let self = self else { return }
    if status == .denied {
        self.showAlert(title: "Location Access Denied", message: "Location services are disabled for this app. To use all features, please enable location access in your device settings.",cancelTitle: "Cancel",confirmTitle: "Open settings") { _ in
                if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(appSettings) {
                        UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                    }
                }
            }
        }
    }
```
Request update location if user has authorization
```swift
locationManager?.requestLocationUpdate()
```
## Credits
- [Murtaza Mehmood](https://www.linkedin.com/in/murtazamehmood/)
