//
//  HaloGeneralContentManager.swift
//  HaloSDK
//
//  Created by Borja Santos-Díez on 10/03/16.
//  Copyright © 2016 MOBGEN Technology. All rights reserved.
//

import Halo

@objc public enum ContentFlags: Int {
    case None, IncludeArchived, IncludeUnpublished, IncludeArchivedAndUnpublished
}

public class HaloContentManager: NSObject {

    static let sharedInstance = HaloContentManager()

    private let content = Halo.Manager.content

    private override init() {
        super.init()
    }

    @objc
    public func instances(moduleIds moduleIds: [String],
                                    offlinePolicy: OfflinePolicy,
                                    success: (NSHTTPURLResponse?, PaginatedContentInstances) -> Void,
                                    failure: (NSHTTPURLResponse?, NSError) -> Void) -> Void {

        let searchOptions = SearchQuery().offlinePolicy(offlinePolicy)

        content.search(searchOptions) { (response, result) in
            switch result {
            case .Success(let data, _):
                if let instances = data {
                    success(response, instances)
                }
            case .Failure(let error):
                failure(response, error)
            }
        }
    }

    @objc
    public func instances(instanceIds instanceIds: [String],
                                      offlinePolicy: OfflinePolicy,
                                      success: (NSHTTPURLResponse?, PaginatedContentInstances) -> Void,
                                      failure: (NSHTTPURLResponse?, NSError) -> Void) -> Void {

        let searchOptions = SearchQuery().offlinePolicy(offlinePolicy)

        content.search(searchOptions) { (response, result) in
            switch result {
            case .Success(let data, _):
                if let instances = data {
                    success(response, instances)
                }
            case .Failure(let error):
                failure(response, error)
            }
        }

    }

}
