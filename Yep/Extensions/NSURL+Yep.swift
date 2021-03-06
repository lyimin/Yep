//
//  NSURL+Yep.swift
//  Yep
//
//  Created by nixzhu on 15/11/9.
//  Copyright © 2015年 Catch Inc. All rights reserved.
//

import Foundation
import YepKit
private let yepHost = "soyep.com"

extension NSURL {

    private var allQueryItems: [NSURLQueryItem] {

        if let components = NSURLComponents(URL: self, resolvingAgainstBaseURL: false), queryItems = components.queryItems {
            return queryItems
        }

        return []
    }

    private func queryItemForKey(key: String) -> NSURLQueryItem? {

        let predicate = NSPredicate(format: "name=%@", key)
        return (allQueryItems as NSArray).filteredArrayUsingPredicate(predicate).first as? NSURLQueryItem
    }
    
    func yep_matchSharedFeed(completion: DiscoveredFeed -> Void) -> Bool {

        guard let host = host where host == yepHost else {
            return false
        }

        guard let pathComponents = pathComponents else {
            return false
        }

        if let first = pathComponents[safe: 1] where first == "groups" {
            if let second = pathComponents[safe: 2] where second == "share" {
                if let sharedToken = queryItemForKey("token")?.value {
                    feedWithSharedToken(sharedToken, failureHandler: nil, completion: { feed in
                        dispatch_async(dispatch_get_main_queue()) {
                            completion(feed)
                        }
                    })

                    return true
                }
            }
        }

        return false
    }

    // make sure put it in last

    func yep_matchProfile(completion: DiscoveredUser -> Void) -> Bool {

        guard let host = host where host == yepHost else {
            return false
        }

        guard let pathComponents = pathComponents else {
            return false
        }

        if let username = pathComponents[safe: 1] {

            discoverUserByUsername(username, failureHandler: nil, completion: { discoveredUser in

                dispatch_async(dispatch_get_main_queue()) {
                    completion(discoveredUser)
                }
            })

            return true
        }

        return false
    }
}

extension NSURL {

    var yep_isNetworkURL: Bool {

        switch scheme {
        case "http", "https":
            return true
        default:
            return false
        }
    }

    var yep_validSchemeNetworkURL: NSURL? {

        if scheme.isEmpty {

            guard let URLComponents = NSURLComponents(URL: self, resolvingAgainstBaseURL: false) else {
                return nil
            }

            URLComponents.scheme = "http"

            return URLComponents.URL

        } else {
            if yep_isNetworkURL {
                return self

            } else {
                return nil
            }
        }
    }
}

