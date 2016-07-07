//
//  GeneralContent.swift
//  HaloSDK
//
//  Created by Borja on 31/07/15.
//  Copyright © 2015 MOBGEN Technology. All rights reserved.
//

import Foundation

/**
 Access point to the General Content. This class will provide methods to obtain the data stored as general content.
 */
public struct ContentManager: HaloManager, ContentProvider {

    public var defaultLocale: Halo.Locale?
    
    init() {}

    public func startup(completionHandler handler: ((Bool) -> Void)?) -> Void {
        
    }

    // MARK: Get instances
    
    public func getInstances(searchOptions: Halo.SearchOptions) -> Halo.Request {
        
        let request = Halo.Request(router: Router.GeneralContentSearch)

        // Copy the options to make it mutable
        var options = searchOptions
        
        // Check offline mode
        if let offline = options.offlinePolicy {
            request.offlinePolicy(offline)
        }
        
        // Set the provided locale or fall back to the default one
        options.locale = options.locale ?? self.defaultLocale
        
        // Process the search options
        request.params(options.body)
        
        return request
    }

}