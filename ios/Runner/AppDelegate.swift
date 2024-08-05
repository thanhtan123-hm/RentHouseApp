import UIKit
import Flutter
import FirebaseCore
//them vao
import GoogleMaps
import flutter_local_notifications
@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
     FirebaseApp.configure()
    //Them vao
     GMSServices.provideAPIKey("AIzaSyAo1hy4bl3PmNJRHtdvNU0mxP4_GhXZwbU")
     FlutterLocalNotificationsPlugin.setPluginRegistrantCallback { (registry) in
         GeneratedPluginRegistrant.register(with: registry)
     }
    GeneratedPluginRegistrant.register(with: self)
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
import FirebaseCore
