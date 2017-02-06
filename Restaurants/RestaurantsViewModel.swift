//
//  RestaurantsViewModel.swift
//  Restaurants
//
//  Created by Harish Saini on 06/02/17.
//  Copyright © 2017 Fueled. All rights reserved.
//

import ReactiveSwift

final class RestaurantsViewModel {
	var dataSource = [Restaurant]()
	let disposable = CompositeDisposable()

	deinit {
		self.disposable.dispose()
	}

	func fetchFoursquareRestaurants() -> SignalProducer<[Restaurant], NSError> {
		return SignalProducer { sink, disposable in
			self.validateLocation().startWithResult { result in
				guard let isValid = result.value, isValid else {
					if let error = result.error {
						sink.send(error: error)
					}
					return
				}
				
				APIInterface.shared.fetchFoursquareRestaurants().startWithResult { result in
					if let error = result.error {
						sink.send(error: error)
						return
					}
					if let restaurants = result.value?.restaurants {
						sink.send(value: restaurants)
						sink.sendCompleted()
					}
				}
			}
		}
	}
	
	func validateLocation() -> SignalProducer<Bool, NSError> {
		return SignalProducer { (sink, disposable) in
			//we can check here if the user granted permission for location, it is true by default now for learnig purpose
			var isValid = true
			if isValid{
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
