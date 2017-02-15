//
//  Manager+Modules.swift
//  HaloSDK
//
//  Created by Borja Santos-Díez on 11/11/15.
//  Copyright © 2015 MOBGEN Technology. All rights reserved.
//

import Foundation

extension CoreManager {
    
    /**
     Get a list of the existing modules for the provided client credentials
     
     - parameter offlinePolicy: Offline policy to be considered when retrieving data
     */
    public func getModules(_ handler: @escaping (HTTPURLResponse?, Result<PaginatedModules?>) -> Void) -> Void {
        return dataProvider.getModules(handler)
    }
    
    public func printModulesMetaData() -> Void {
        
        let request = Halo.Request<[ModuleInfo]>(router: Router.modules).skipPagination().params(["withFields": true]).responseParser { data in
            
            if let collection = data as? [[String: Any?]] {
                return collection.map { ModuleInfo.fromDictionary($0) }
            }
            
            return nil
        }
        
        do {
            try request.responseObject { response, result in
                switch result {
                case .success(let data, _):
                    Manager.core.logMessage(data.debugDescription, level: .info)
                case .failure(let error):
                    Manager.core.logMessage(error.description, level: .error)
                }
            }
        } catch {
            Manager.core.logMessage(error.localizedDescription, level: .error)
        }
    }
    
    public func printModuleMetaData(moduleId: String) -> Void {
        
        let request = Halo.Request<ModuleInfo>(router: Router.module(moduleId)).params(["withFields": true]).responseParser { data in
            
            if let dict = data as? [String: Any?] {
                return ModuleInfo.fromDictionary(dict)
            }
            
            return nil
        }
        
        do {
            try request.responseObject { response, result in
             
                switch result {
                case .success(let info, _):
                    Manager.core.logMessage(info.debugDescription, level: .info)
                case .failure(let error):
                    Manager.core.logMessage(error.description, level: .error)
                }
                
            }
        } catch {
            Manager.core.logMessage(error.localizedDescription, level: .error)
        }
        
    }
    
}
