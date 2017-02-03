//
//  Venue+Api.swift
//  Restaurants
//
//  Created by Harish Saini on 03/02/17.
//  Copyright © 2017 Fueled. All rights reserved.
//

import Foundation
import PromiseKit

extension Venue {
	static func fetchFoursquareVenues() ->  Promise<[Restaurant]> {
		let params = ["client_id": "5AYW35NKNLOX3RQTSRUXBXLBF5IA1DJHWNZXC4KPHV1XZ4W4",
		              "client_secret": "X1BBQH5YDRZSRGJS3G5U5EVKUKTPZXKDXIENXTVINABGXPOL",
		              "v": "20161215",
		              "ll": "28.535516,77.391026",
		              "section": "food",
		              "limit": "50",
		              "sortByDistance": "1"]
		
		return StoreApiClient.sharedClient.GET(path: "venues/explore" , parameters: params as [String : AnyObject]?).then { result in
			guard let result = result as? [String: Any], let responseData = result["response"] as? [String: Any] else {
				return Promise(error: APIError.BadStatusCode(statusCode: 1000, message: "Not able to parse"))
			}
			guard let groups = responseData["groups"] as? [[String: Any]] else {
				return Promise(error: APIError.BadStatusCode(statusCode: 1000, message: "Not able to parse"))

			}
			guard let groupsFirstObject = groups.first! as? [String: Any] else {
				return Promise(error: APIError.BadStatusCode(statusCode: 1000, message: "Not able to parse"))
			}
			guard let items = groupsFirstObject["items"] as? [[String: Any]] else {
				return Promise(error: APIError.BadStatusCode(statusCode: 1000, message: "Not able to parse"))
			}
			
			print("fetchFoursquareVenues response : \(items)")
			var restaurants = [Restaurant]()
			for item in items {
				let restaurant = Restaurant(data: item)
				restaurants.append(restaurant)
			}
			print("restaurants : \(restaurants)")
			return Promise(value: restaurants)
		}
	}

}
