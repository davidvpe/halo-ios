//
//  Protocols.swift
//  HaloSDK
//
//  Created by Borja Santos-Díez on 20/04/16.
//  Copyright © 2016 MOBGEN Technology. All rights reserved.
//

/**
 This delegate will provide methods that will act as interception points in the setup process of the SDK
 within the application
 */

import Foundation
import UserNotifications
import UIKit

@objc(HaloManagerDelegate)
public protocol ManagerDelegate {

    /**
     This delegate method provides full freedom to create the user that will be registered by the application.

     - returns: The newly created user
     */
    @objc(managerWillSetupDevice:)
    func managerWillSetupDevice(_ device: Halo.Device) -> Void

}

@objc
public protocol HaloAddon {

    var addonName: String { get }

    @objc(setup:completionHandler:)
    func setup(haloCore core: Halo.CoreManager, completionHandler handler: ((HaloAddon, Bool) -> Void)?) -> Void
    
    @objc(startup:core:completionHandler:)
    func startup(app: UIApplication, haloCore core: Halo.CoreManager, completionHandler handler: ((HaloAddon, Bool) -> Void)?) -> Void

    @objc(willRegisterAddon:)
    func willRegisterAddon(haloCore core: Halo.CoreManager) -> Void
    
    @objc(didRegisterAddon:)
    func didRegisterAddon(haloCore core: Halo.CoreManager) -> Void

}

@objc
public protocol HaloDeviceAddon: HaloAddon {
    
    @objc(willRegisterDevice:)
    func willRegisterDevice(haloCore core: Halo.CoreManager) -> Void
    
    @objc(didRegisterDevice:)
    func didRegisterDevice(haloCore core: Halo.CoreManager) -> Void

}

@objc
public protocol HaloLifecycleAddon: HaloAddon {
    
    @objc(applicationWillFinishLaunching:core:)
    func applicationWillFinishLaunching(_ app: UIApplication, core: Halo.CoreManager) -> Bool
    
    @objc(applicationDidFinishLaunching:core:launchOptions:)
    func applicationDidFinishLaunching(_ app: UIApplication, core: Halo.CoreManager, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool
    
    @objc(applicationDidEnterBackground:core:)
    func applicationDidEnterBackground(_ app: UIApplication, core: Halo.CoreManager) -> Void
    
    @objc(applicationDidBecomeActive:core:)
    func applicationDidBecomeActive(_ app: UIApplication, core: Halo.CoreManager) -> Void
    
    @objc(applicationWillChangeEnvironment:core:)
    func applicationWillChangeEnvironment(_ app: UIApplication, core: Halo.CoreManager) -> Void
    
    @objc(applicationDidChangeEnvironment:core:)
    func applicationDidChangeEnvironment(_ app: UIApplication, core: Halo.CoreManager) -> Void
}

@objc
public protocol HaloDeeplinkingAddon: HaloAddon {
    
    @objc(application:openURL:options:)
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any]) -> Bool
    
    @objc(application:openURL:sourceApplication:annotation:)
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool

}


@objc
public protocol HaloNotificationsAddon: HaloAddon {

    @objc(application:didRegisterForRemoteNotificationsWithDeviceToken:core:)
    func application(_ app: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data, core: Halo.CoreManager) -> Void
    
    @objc(application:didFailToRegisterForRemoteNotificationsWithError:core:)
    func application(_ app: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError, core: Halo.CoreManager) -> Void

    @objc(application:didReceiveRemoteNotification:core:userInteraction:fetchCompletionHandler:)
    func application(_ app: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], core: Halo.CoreManager, userInteraction user: Bool, fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) -> Void
    
    @available(iOS 10.0, *)
    @objc(userNotificationCenter:didReceive:core:completionHandler:)
    @available(iOSApplicationExtension 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, core: Halo.CoreManager, fetchCompletionHandler completionHandler: @escaping () -> Void) -> Void
}

@objc
public protocol HaloNetworkAddon: HaloAddon {

    @objc(willPerformRequest:)
    func willPerformRequest(_ req: URLRequest) -> Void
    
    @objc(didPerformRequest:time:response:)
    func didPerformRequest(_ req: URLRequest, time: TimeInterval, response: URLResponse?) -> Void

}

/// Other protocols

@objc
public protocol HaloManager {

    @objc(startup:completionHandler:)
    func startup(_ app: UIApplication, completionHandler handler: ((Bool) -> Void)?) -> Void

}
