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
	static func fetchFoursquareVenues() ->  Promise<String> {
		let params = ["client_id": "5AYW35NKNLOX3RQTSRUXBXLBF5IA1DJHWNZXC4KPHV1XZ4W4",
		              "client_secret": "X1BBQH5YDRZSRGJS3G5U5EVKUKTPZXKDXIENXTVINABGXPOL",
		              "v": "20161215",
		              "ll": "28.535516,77.391026",
		              "section": "food",
		              "limit": "50",
		              "sortByDistance": "1"]
		return StoreApiClient.sharedClient.GET(path: "venues/explore" , parameters: params as [String : AnyObject]?).then { result in
			guard let result = result as? [String: Any], let responseData = result["data"] as? [String: Any] else {
				return Promise(value: "error")
			}
			print("fetchFoursquareVenues response : \(responseData)")
			return Promise(value: "success")
		}
	}

}
