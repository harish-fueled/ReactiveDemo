//
//  RestaurantsViewModel.swift
//  Restaurants
//
//  Created by Harish Saini on 06/02/17.
//  Copyright © 2017 Fueled. All rights reserved.
//

import ReactiveSwift

final class RestaurantViewModel {
	
	var restaurant: Restaurant?
	var name: String {
		return restaurant?.name ?? ""
	}

	required init(restaurant: Restaurant) {
		self.restaurant = restaurant
	}

	func validateLocation() -> SignalProducer<Bool, NSError> {
		return SignalProducer { (sink, disposable) in
			//we can check here if the user granted permission for location, it is true by default now for learnig purpose
			var isValid = true
			if isValid {
				sink.send(value: true)
				sink.sendCompleted()
			} else {
				let userInfo = [NSLocalizedDescriptionKey: "Location not found"]
				let error = NSError(domain: "Location", code: 0, userInfo: userInfo)
				sink.send(error: error)
			}
		}
	}
}
