//
//  FoursquareRestaurantsResponse.swift
//  Restaurants
//
//  Created by Harish Saini on 06/02/17.
//  Copyright © 2017 Fueled. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreData

final class FoursquareRestaurantsResponse {
	var user: User?
}

extension FoursquareRestaurantsResponse: JSONParsing {
	static func parse (json: JSON, context: NSManagedObjectContext, completionBlock: @escaping ((SignUpResponse?, NSError?) -> Void)) {
//		let responseObject = SignUpResponse()
//		if json[APIKeys.Message].error != nil {
//			User.parse(json: json, context: context, completionBlock: { (user, error) in
//				if let user = user {
//					responseObject.user = user
//					completionBlock(responseObject, nil)
//				} else {
//					completionBlock(nil, error)
//				}
//			})
//		} else {
//			let userInfo = [NSLocalizedDescriptionKey: json[APIKeys.Message].stringValue]
//			let error = NSError(domain: "", code: 0, userInfo: userInfo)
//			completionBlock(nil, error)
//		}
	}
}
