# kinopio-apple

Native app for apple platforms

# Primary Files

| File                                      | Description                                     |
| :---------------------------------------- | :---------------------------------------------- |
| Shared/..                                 | Code that is shared among all targets           |
| Shared/Configuration                      | Configuration file for all targets              |
| Shared/Networking/..                      | All networking related code                     |
| Shared/Extensions/..                      | Useful Swift extensions                         |
| Shared/Models/..                          | Kinopio model definitions for JSON parsing etc. |
| Kinopio/KinopioApp                        | Root file of the main app target                |
| KinopioShareExtension/ShareViewController | Root file of the share extension target         |
| WidgetExtension/KinopioWidgetBundle       | Root file of home and lock screen widgets       |

# How to build

- Rename Kinopio.xcconfig.template to Kinopio.xcconfig and update your
  BundlePrefix, TeamID.
