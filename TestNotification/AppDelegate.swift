//
//  AppDelegate.swift
//  TestNotification
//
//  Created by Gerardo Castillo  on 6/28/19.
//  Copyright © 2019 multiva. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging
import FirebaseInstanceID
import UserNotifications
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate{

    var window: UIWindow?

    let gcmMessageIDKey = "gcm.message_id"
    let preferences = UserDefaults.standard
    var appName = ""
    var isFistFireConfigured = false
    
    let firstAppSenderIdString = "1:217550810621:ios:83adc902246510c4"
    let secondAppSenderIdString = "1:310493013350:ios:83adc902246510c4"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //Messaging.messaging().delegate = self
        FirebaseApp.configure()
         //self.configureApp(googleID:Constants.googleID,iOSID:Constants.iOSID,app: Constants.appName)
        // Override point for customization after application launch.
        let fireOptions = FirebaseOptions(googleAppID: secondAppSenderIdString, gcmSenderID: "217550810621")
        let app = FirebaseApp.app(name: "app2")
        app.configure(name:  "app2", options: fireOptions)
        Messaging.messaging().delegate = self
        //configureApp(googleID: Constants.googleID, iOSID: Constants.iOSID, app Constants.appNameCobroSPEI)
      //  FirebaseApp.configure()
        //self.configureApp(googleID:Constants.googleID,iOSID:Constants.iOSID,app: Constants.appName)
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self

            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]

            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }

        application.registerForRemoteNotifications()
        
//        FirebaseApp.configure()
//        //self.configureApp(googleID:Constants.googleID,iOSID:Constants.iOSID,app: Constants.appName)
//        // Override point for customization after application launch.
//         let fireOptions = FirebaseOptions(googleAppID: secondAppSenderIdString, gcmSenderID: "310493013350")
//        FirebaseApp.configure(name:  "app2", options: fireOptions)
        InstanceID.instanceID().instanceID { (result, error) in
            debugPrint("----- \(result?.token)" )
        }
        
        return true
    }

    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
    // My funtions
    
    func configureApp(googleID: String, iOSID: String, app: String)
    {
        appName = app
        //let fireOptions = FirebaseOptions(googleAppID: "1:310493013350:ios:727bcbb5d9804942", gcmSenderID: "310493013350")
        let googleAppID = String(format: "1:%@:ios:%@", googleID,iOSID)
        debugPrint("--- \(googleAppID)")
        let fireOptions = FirebaseOptions(googleAppID: googleAppID, gcmSenderID: googleID)
        NSLog("configureApp %@ > %@", appName, fireOptions)
        // Configurar FirebaseApp, si existe una app por defecto eliminarla
        let app = FirebaseApp.app()
        app?.delete({ (true) in
            debugPrint("Firebase app borrada")
        })
        FirebaseApp.configure(options: fireOptions)
        debugPrint("total apps: \(FirebaseApp.allApps)")
        debugPrint("token2: \(Messaging.messaging().apnsToken)")
        
       // FirebaseApp.configure()
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo:
        [AnyHashable: Any]) {
        if let messageID = userInfo[gcmMessageIDKey] {
            print("\n1. Message ID: \(messageID)")
        }
        print(userInfo)
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo:
        [AnyHashable: Any],fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult)
        -> Void) {
        if let messageID = userInfo[gcmMessageIDKey] {
            print("\n2. Message ID: \(messageID)")
        }
        print(userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError
        error: Error) {
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken
        deviceToken: Data) {
        let tokenString = deviceToken.reduce("", {$0 + String(format: "%02X", $1)})
        print("deviceToken: \(tokenString)")
        // With swizzling disabled you must set the APNs token here.
        
        Messaging.messaging().apnsToken = deviceToken
        InstanceID.instanceID().token(withAuthorizedEntity: "217550810621", scope: InstanceIDScopeFirebaseMessaging, options: nil) { (result, error) in
            if error != nil {
                debugPrint("token 2 \(result)")
            }
        }
        
        Messaging.messaging().retrieveFCMToken(forSenderID: "217550810621", completion: { (token, error) in
            if error != nil{
                debugPrint("token3 \(token)")
            }
        })
//
//        Messaging.messaging().retrieveFCMToken(forSenderID: firstAppSenderIdString) { (message, error) in
//            print("FCM token for app1: \(message ?? "")")
//        }
//        Messaging.messaging().retrieveFCMToken(forSenderID: secondAppSenderIdString) { (message, error) in
//            print("FCM token for app2: \(message ?? "")")
//        }
    }
    
}

@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {
    // Configurar presentación de las notificaciones
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) ->
        
        Void) {
        let userInfo = notification.request.content.userInfo
        if let messageID = userInfo[gcmMessageIDKey] {
            print("\n3. Message ID: \(messageID)")
        }
        print(userInfo)
        completionHandler([.alert, .badge, .sound])
}
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        if let messageID = userInfo[gcmMessageIDKey] {
            print("\n4. Message ID: \(messageID)")
        }
        print(userInfo)
        completionHandler()
    }
}


extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("Firebase token para app: \(appName) \n\(fcmToken)")
        
//        isFistFireConfigured = true
//        //Guardar en las preferencias
//        preferences.set(fcmToken, forKey: appName)
//        // Save to disk
//        let didSave = preferences.synchronize()
//        if !didSave {
//            print("Error al sincronizar las preferencias")
//        }
//        //Configurar el segundo proyecto de Firebase (Banxico)
//        if(isFistFireConfigured)
//        {
//
//            configureApp(googleID: Constants.googleIDCobroSPEI, iOSID: Constants.iOSID, app:
//                Constants.appNameCobroSPEI)
//            isFistFireConfigured = false
//        }
    }
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        
        print("\nReceived data message foreground: \(remoteMessage.appData)")
    }
}




