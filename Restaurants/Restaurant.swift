//
//  Restaurant.swift
//  Restaurants
//
//  Created by Harish Saini on 03/02/17.
//  Copyright © 2017 Fueled. All rights reserved.
//

import Foundation

struct Restaurant {
	var name = ""
	var url = ""
	var rating = ""
	var priceMessage = ""
	
	init(data: [String: Any]? = nil) {
		guard let data = data else {
			return
		}
		if let venue = data["venue"] as? [String: Any] {
			if let name = venue["name"] as? String {
				self.name = name
			}
			if let url = venue["url"] as? String {
				self.url = url
			}
		}
	}
}
