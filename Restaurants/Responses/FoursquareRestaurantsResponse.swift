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
	var restaurants: [Restaurant]?
}

extension FoursquareRestaurantsResponse: JSONParsing {
	static func parse (json: JSON, context: NSManagedObjectContext, completionBlock: @escaping ((FoursquareRestaurantsResponse?, NSError?) -> Void)) {
		let responseObject = FoursquareRestaurantsResponse()
		

		guard let result = json.dictionaryObject, let responseData = result["response"] as? [String: Any] else {
			let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Not able to parse"])
			completionBlock(nil, error)
			return
		}
		guard let groups = responseData["groups"] as? [[String: Any]] else {
			let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Not able to parse"])
			completionBlock(nil, error)
			return
			
		}
		guard let groupsFirstObject = groups.first else {
			let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Not able to parse"])
			completionBlock(nil, error)
			return
		}
		guard let items = groupsFirstObject["items"] as? [[String: Any]] else {
			let error = NSError(domain: "", code: 0, userInfo: [NSLocalizedDescriptionKey: "Not able to parse"])
			completionBlock(nil, error)
			return
		}
		
		print("fetchFoursquareVenues response : \(items)")
		var restaurants = [Restaurant]()
		for item in items {
			let restaurant = Restaurant(data: item)
			restaurants.append(restaurant)
		}
		print("restaurants : \(restaurants)")
		responseObject.restaurants = restaurants
		completionBlock(responseObject, nil)
	}
}
