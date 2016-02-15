//
//  NetworkManager+GeneralContent.swift
//  HaloSDK
//
//  Created by Borja Santos-Díez on 05/08/15.
//  Copyright © 2015 MOBGEN Technology. All rights reserved.
//

import Foundation
import Alamofire

public struct GeneralContentFlag : OptionSetType {
    
    public let rawValue: UInt
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    public static let IncludeArchived = GeneralContentFlag(rawValue: 1)
    public static let IncludeUnpublished = GeneralContentFlag(rawValue: 2)
}

extension NetworkManager {

    /**
    Obtain the existing instances for a given General Content module

    - parameter moduleId:           Internal id of the module to be requested
    - parameter completionHandler:  Closure to be executed when the request has finished
    */
    func generalContentInstances(moduleIds: [String], flags: GeneralContentFlag, fetchFromNetwork network: Bool = true, populate: Bool? = false, completionHandler handler: ((Halo.Result<[Halo.GeneralContentInstance], NSError>) -> Void)? = nil) -> Void {

        var params: [String: AnyObject] = [
            "module" : moduleIds,
            "populate" : populate!
        ]
        
        if !flags.contains(GeneralContentFlag.IncludeArchived) {
            params["archived"] = "false"
        }
        
        let unpublished = flags.contains(GeneralContentFlag.IncludeUnpublished)
        
        Halo.Request<[[String: AnyObject]]>(router: Router.GeneralContentInstances(params)).response { [weak self] (request, response, result) in

            if let strongSelf = self {
                switch result {
                case .Success(let data, let cached):
                    let arr = strongSelf.parseGeneralContentInstances(data, includeUnpublished: unpublished)
                    handler?(.Success(arr, cached))
                case .Failure(let error):
                    handler?(.Failure(error))
                }
            }
        }
    }

    func generalContentInstance(instanceId: String, fetchFromNetwork network: Bool = true, populate: Bool? = false, completionHandler handler: ((Halo.Result<Halo.GeneralContentInstance, NSError>) -> Void)? = nil) -> Void {
        
        let params: [String: AnyObject] = ["populate" : populate!]
        
        self.startRequest(request: Halo.Request<[String: AnyObject]>(router: Router.GeneralContentInstance(instanceId, params))) { (request, response, result) in
            
            switch result {
            case .Success(let data, let cached):
                handler?(.Success(GeneralContentInstance(data), cached))
            case .Failure(let error):
                handler?(.Failure(error))
            }
        }
    }
    
    func generalContentInstances(instanceIds: [String], fetchFromNetwork network: Bool = true, populate: Bool? = false, completionHandler handler: ((Halo.Result<[Halo.GeneralContentInstance], NSError>) -> Void)? = nil) -> Void {
        
        let params: [String: AnyObject] = [
            "id" : instanceIds,
            "populate" : populate!
        ]
        
        self.startRequest(request: Halo.Request<[GeneralContentInstance]>(router: Router.GeneralContentInstances(params))) { (request, response, result) in
            
            switch result {
            case .Success(let data, let cached):

//                var items = []
//
//                // Create the paginated result
//                if let i = data["items"] as? [[String: AnyObject]] {
//                    items = i.map({ GeneralContentInstance($0) })
//                }

                handler?(.Success(data, cached))
            case .Failure(let error):
                handler?(.Failure(error))
            }
        }
    }
    
    /**
    Utility function to parse the JSON coming from the request into an array of General Content instances

    - parameter instances:   Array of dictionaries (JSON) coming directly from the response

    - returns Array of parsed General Content instances
    */
    private func parseGeneralContentInstances(instances: [[String: AnyObject]], includeUnpublished: Bool) -> [GeneralContentInstance] {
        let inst = instances.map({ GeneralContentInstance($0) })
        
        return inst.filter { (instance) -> Bool in
            
            if includeUnpublished {
                return !instance.isRemoved()
            } else {
                return instance.isPublished() && !instance.isRemoved()
            }
            
        }
    }

}