//
//  NetworkManager+User.swift
//  HaloSDK
//
//  Created by Borja Santos-Díez on 26/08/15.
//  Copyright © 2015 MOBGEN Technology. All rights reserved.
//

import Foundation

extension NetworkManager {

    func userParser(data: AnyObject) -> Halo.User? {
        if let dict = data as? [String: AnyObject] {
            return User.fromDictionary(dict: dict)
        }
        return nil
    }
    
    func getUser(user: Halo.User, completionHandler handler: ((NSHTTPURLResponse?, Halo.Result<Halo.User?>) -> Void)? = nil) -> Void {

        if let id = user.id {

            let request = Halo.Request<Halo.User>(router: Router.SegmentationGetUser(id))
            try! request.responseParser(parser: self.userParser).responseObject(completionHandler: handler)

        } else {
            handler?(nil, .Success(user, false))
        }

    }

    /**
    Create or update a user in the remote server, containing all the user details (devices, tags, etc)

    - parameter user:    User object containing all the information to be sent
    - parameter handler: Closure to be executed after the request has completed
    */
    func createUpdateUser(user: Halo.User, completionHandler handler: ((NSHTTPURLResponse?, Halo.Result<Halo.User?>) -> Void)? = nil) -> Void {

        /// Decide whether to create or update the user based on the presence of an id
        var request: Halo.Request<Halo.User>

        if let id = user.id {
            request = Halo.Request(router: Router.SegmentationUpdateUser(id, user.toDictionary()))
        } else {
            request = Halo.Request(router: Router.SegmentationCreateUser(user.toDictionary()))
        }

        try! request.responseParser(parser: self.userParser).responseObject(completionHandler: handler)
    }
}
