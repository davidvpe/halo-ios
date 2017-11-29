//
//  CoreManager.swift
//  HaloSDK
//
//  Created by Borja Santos-Díez on 29/02/16.
//  Copyright © 2016 MOBGEN Technology. All rights reserved.
//

import Foundation
import UIKit

@objc(HaloCoreManager)
open class CoreManager: NSObject, HaloManager, Logger {
    
    var app: UIApplication?
    var completionHandler: ((Bool) -> Void)?
    
    /// Delegate that will handle launching completion and other important steps in the flow
    public var delegate: ManagerDelegate?
    
    public internal(set) var loggers: [Logger] = []
    
    public internal(set) var isReady: Bool = false
    
    public internal(set) var isStarting: Bool = false
    
    public internal(set) var dataProvider: DataProvider = DataProviderManager.online
    
    ///
    public var logLevel: LogLevel = .warning
    
    ///
    let lockQueue = DispatchQueue(label: "com.mobgen.halo.lockQueue", attributes: [])
    
    public fileprivate(set) var environment: HaloEnvironment = .prod {
        willSet {
            if let app = self.app {
                self.getAddons(type: HaloLifecycleAddon.self).forEach { $0.applicationWillChangeEnvironment(app, core: self) }
            }
        }
        didSet {
            Router.baseURL = environment.baseUrl
            Router.userToken = nil
            Router.appToken = nil
            Manager.auth.currentUser = nil
            AuthProfile.removeProfile()
            
            if let app = self.app {
                self.getAddons(type: HaloLifecycleAddon.self).forEach { $0.applicationDidChangeEnvironment(app, core: self) }
            }
        }
    }
    
    public var defaultOfflinePolicy: OfflinePolicy = .none {
        didSet {
            switch defaultOfflinePolicy {
            case .none: self.dataProvider = DataProviderManager.online
            case .loadAndStoreLocalData: self.dataProvider = DataProviderManager.onlineOffline
            case .returnLocalDataDontLoad: self.dataProvider = DataProviderManager.offline
            }
        }
    }
    
    public var defaultAuthenticationMode: AuthenticationMode = .app
    
    open var numberOfRetries: Int = 0
    
    public var appCredentials: Credentials?
    public var userCredentials: Credentials?
    
    public var env: String?
    
    public var frameworkVersion: String {
        return Bundle(identifier: "com.mobgen.Halo")!.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
    }
    
    public var configuration = "Halo"
    
    /// Variable to decide whether to enable system tags or not
    public var enableSystemTags: Bool = false
    
    /// Instance holding all the device-related information
    public var device: Device?
    
    public internal(set) var addons: [HaloAddon] = []
    
    private lazy var __once: (UIApplication, ((Bool) -> Void)?) -> Void = { app, handler in
        
        self.completionHandler = { success in
            self.isReady = success
            self.isStarting = false
            Halo.Manager.network.restartCachedTasks()
            handler?(success)
        }
        
        Router.userToken = nil
        Router.appToken = nil
        
        Manager.network.startup(app) { success in
            
            if !success {
                DispatchQueue.main.async {
                    self.completionHandler?(false)
                }
                return
            }
            
            let bundle = Bundle.main
            
            if let path = bundle.path(forResource: self.configuration, ofType: "plist") {
                
                if let data = NSDictionary(contentsOfFile: path) {
                    let clientIdKey = CoreConstants.clientIdKey
                    let clientSecretKey = CoreConstants.clientSecretKey
                    let usernameKey = CoreConstants.usernameKey
                    let passwordKey = CoreConstants.passwordKey
                    let environmentKey = CoreConstants.environmentSettingKey
                    
                    if(self.appCredentials != nil) {
                        self.setAppCredentials(withClientId: self.appCredentials!.username, withClientSecret: self.appCredentials!.password)
                    } else if let clientId = data[clientIdKey] as? String, let clientSecret = data[clientSecretKey] as? String {
                        self.setAppCredentials(withClientId: clientId,withClientSecret: clientSecret)
                    }
                    
                    if(self.appCredentials != nil) {
                        self.setUserCredentials(withUsername: self.appCredentials!.username, withPassword: self.appCredentials!.password)
                    } else if let username = data[usernameKey] as? String, let password = data[passwordKey] as? String {
                        self.setUserCredentials(withUsername: username, withPassword: password)
                    }
                    
                    if let tags = data[CoreConstants.enableSystemTags] as? Bool {
                        self.enableSystemTags = tags
                    }
                    
                    if(self.env != nil) {
                        self.setEnvironment(self.env!)
                    } else if let env = data[environmentKey] as? String {
                        self.setEnvironment(env)
                    }
                }
            } else {
                self.logMessage("No configuration .plist found", level: .warning)
            }
            
            self.checkNeedsUpdate()
            self.setup()
        }
    }
    
    fileprivate override init() {
        super.init()
    }
    
    /**
     Allows changing the current appcredentials.
     */
    public func setAppCredentials(withClientId: String , withClientSecret: String) {
        self.appCredentials = Credentials(clientId: withClientId, clientSecret: withClientSecret)
    }
    
    /**
     Allows changing the current user credential.
     */
    public func setUserCredentials(withUsername: String , withPassword: String) {
        self.userCredentials = Credentials(username: withUsername, password: withPassword)
    }
    
    /**
     Allows changing the current environment against which the connections are made.
     
     - parameter env:   The env to set
     */
    public func setEndpoint(_ env: String) {
        self.env = env
    }
    
    /**
     Allows changing the current environment against which the connections are made. It will imply a setup process again
     and that is why a completion handler can be provided. Once the process has finished and the environment is
     properly configured, it will be called.
     
     - parameter env:   The new environment to be set
     - parameter handler:       Closure to be executed once the setup is done again and the environment is properly configured
     */
    public func setEnvironment(_ env: HaloEnvironment, completionHandler handler: ((Bool) -> Void)? = nil) {
        
        self.environment = env
        
        // Save the environment
        KeychainHelper.set(env.description, forKey: CoreConstants.environmentSettingKey)
        
        self.completionHandler = handler
        self.setup()
    }
    
    fileprivate func setup() {
        
        let handler: (Bool) -> Void = { success in
            
            if !success {
                DispatchQueue.main.async {
                    self.completionHandler?(false)
                }
                return
            }
            
            if let authProfile = AuthProfile.loadProfile() {
                Manager.core.logMessage("Loading stored auth profile for the current environment", level: .info)
                // Login and get user details (in case there have been updates)
                Manager.auth.login(authProfile: authProfile, stayLoggedIn: true) { response, result in
                    
                    var success = true
                    
                    switch result {
                    case .success(_, _): break
                    case .failure(_): success = false
                    }
                    
                    DispatchQueue.main.async {
                        self.completionHandler?(success)
                    }
                }
            } else {
                Manager.core.logMessage("No stored auth profile found for this environment", level: .info)
                DispatchQueue.main.async {
                    self.completionHandler?(success)
                }
            }
        }
        
        // Configure device
        self.configureDevice { success in
            if success {
                // Configure all the registered addons
                self.setupAndStartAddons { success in
                    if success {
                        
                        if let device = self.device {
                            self.delegate?.managerWillSetupDevice(device)
                        }
                        
                        self.registerDevice { success in
                            handler(success)
                        }
                    } else {
                        handler(false)
                    }
                }
            } else {
                handler(false)
            }
        }
    }
    
    fileprivate func setEnvironment(_ env: String) {
        switch env.lowercased() {
        case "int": self.environment = .int
        case "qa": self.environment = .qa
        case "prod": self.environment = .prod
        case "stage": self.environment = .stage
        default: self.environment = .custom(env)
        }
        
        // Save the environment
        KeychainHelper.set(self.environment.description, forKey: CoreConstants.environmentSettingKey)
    }
    
    @objc(startup:completionHandler:)
    public func startup(_ app: UIApplication, completionHandler handler: ((Bool) -> Void)? = nil) {
        
        self.app = app
        self.completionHandler = handler
        
        // Check if there's a stored environment
        if let env = KeychainHelper.string(forKey: CoreConstants.environmentSettingKey) {
            self.setEnvironment(env)
        }
        
        self.isStarting = true
        
        DispatchQueue.global(qos: .background).async {
            self.__once(app, handler)
        }
        
    }
    
    /**
     Pass through the push notifications setup. To be called within the method in the app delegate.
     
     - parameter app: Application being configured
     - parameter deviceToken: Token obtained for the current device
     */
    @objc(application:didRegisterForRemoteNotificationsWithDeviceToken:)
    open func application(_ app: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        Manager.core.logMessage("Successfully registered for remote notifications with token \(deviceToken.description)", level: .info)
        
        self.addons.forEach { [weak self] addon in
            if let notifAddon = addon as? HaloNotificationsAddon, let strongSelf = self {
                notifAddon.application(app, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken, core: strongSelf)
            }
        }
    }
    
    /**
     Pass through the push notifications setup. To be called within the method in the app delegate.
     
     - parameter app: Application being configured
     - parameter error: Error thrown during the process
     */
    @objc(application:didFailToRegisterForRemoteNotificationsWithError:)
    open func application(_ app: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        
        logMessage(HaloError.failedToRegisterForRemoteNotifications(error.localizedDescription).description, level: .error)
        
        self.addons.forEach { (addon) in
            if let notifAddon = addon as? HaloNotificationsAddon {
                notifAddon.application(app, didFailToRegisterForRemoteNotificationsWithError: error, core: self)
            }
        }
    }
    
    @objc(application:didReceiveRemoteNotification:userInteraction:)
    open func application(_ app: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], userInteraction user: Bool) {
        
        self.addons.forEach { (addon) in
            if let notifAddon = addon as? HaloNotificationsAddon {
                notifAddon.application(app, didReceiveRemoteNotification: userInfo, core: self, userInteraction: user, fetchCompletionHandler: { _ in })
            }
        }
    }
    
    @objc(application:didReceiveRemoteNotification:userInteraction:fetchCompletionHandler:)
    open func application(_ app: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], userInteraction user: Bool, fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        self.addons.forEach { (addon) in
            if let notifAddon = addon as? HaloNotificationsAddon {
                notifAddon.application(app, didReceiveRemoteNotification: userInfo, core: self, userInteraction: user, fetchCompletionHandler: completionHandler)
            }
        }
    }
    
    @objc(applicationWillFinishLaunching:)
    open func applicationWillFinishLaunching(_ application: UIApplication) -> Bool {
        return self.addons.reduce(true) { $0 && ($1 as? HaloLifecycleAddon)?.applicationWillFinishLaunching(application, core: self) ?? true }
    }
    
    @objc(applicationDidFinishLaunching:launchOptions:)
    open func applicationDidFinishLaunching(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        return self.addons.reduce(true) { $0 && ($1 as? HaloLifecycleAddon)?.applicationDidFinishLaunching(application, core: self, didFinishLaunchingWithOptions: launchOptions) ?? true }
    }
    
    @objc(applicationDidBecomeActive:)
    open func applicationDidBecomeActive(_ app: UIApplication) {
        self.addons.forEach { ($0 as? HaloLifecycleAddon)?.applicationDidBecomeActive(app, core: self) }
    }
    
    @objc(applicationDidEnterBackground:)
    open func applicationDidEnterBackground(_ app: UIApplication) {
        self.addons.forEach { ($0 as? HaloLifecycleAddon)?.applicationDidEnterBackground(app, core: self) }
    }
    
    @objc(application:openURL:options:)
    open func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return self.addons.reduce(false) { $0 || ($1 as? HaloDeeplinkingAddon)?.application(app, open: url, options: options) ?? false }
    }
    
    @objc(application:openURL:sourceApplication:annotation:)
    open func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        return self.addons.reduce(false) { $0 || ($1 as? HaloDeeplinkingAddon)?.application(application, open: url, sourceApplication: sourceApplication, annotation: annotation) ?? false }
    }
    
    fileprivate func checkNeedsUpdate(_ handler: ((Bool) -> Void)? = nil) -> Void {
        
        do {
            try Request<Any>(.versionCheck).serverCache(seconds: 86400).response { (_, result) in
                switch result {
                case .success(let data as [[String: AnyObject]], _):
                    if let info = data.first, let minIOS = info["minIOS"] {
                        if minIOS.compare(self.frameworkVersion, options: .numeric) == .orderedDescending {
                            let changelog = info["iosChangeLog"] as! String
                            
                            self.logMessage("The version of the Halo SDK you are using is outdated. Please update to ensure there are no breaking changes. Minimum version: \(minIOS). Version changelog: \(changelog)", level: .warning)
                        }
                    }
                    handler?(true)
                case .failure(_):
                    handler?(false)
                default:
                    break
                }
            }
        } catch {
            self.logMessage("There was an error checking the current version \(error.localizedDescription)", level: .error)
            handler?(false)
        }
    }
    
    public func addLogger(_ logger: Logger) {
        self.loggers.append(logger)
    }
    
    public func addLoggers(_ loggers: [Logger]) {
        self.loggers.append(contentsOf: loggers)
    }
    
    // MARK: Logger protocol
    
    public func logMessage(_ message: String, level: LogLevel) {
        
        if self.logLevel.rawValue >= level.rawValue {
            self.loggers.forEach { $0.logMessage(message, level: level) }
        }
    }
    
}

public extension Manager {
    
    public static let core: CoreManager = {
        return CoreManager()
    }()
    
}
