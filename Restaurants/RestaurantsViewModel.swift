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
	
	func fetchFoursquareVenues() -> SignalProducer<FoursquareRestaurantsResponse, NSError> {
		return SignalProducer { sink, disposable in
			self.validateLocation().startWithResult { result in
				guard let isValid = result.value, isValid else {
					if let error = result.error {
						sink.send(error: error)
					}
					return
				}
				
//				let _ = Restaurant.fetchFoursquareVenues().then { restaurants -> Void in
//					self.dataSource = restaurants
//					sink.send(value: loginResult.value!)
//					sink.sendCompleted()
//
////					self.tableView.reloadData()
//				}.catch(execute: { error in
//					sink.send(error: error)
//					return
//				})
				APIInterface.shared.fetchFoursquareRestaurants().startWithResult{ result in
//				APIInterface.shared.loginUser(with: email, and: password).startWithResult { loginResult in
					if let error = loginResult.error {
						sink.send(error: error)
						return
					}
					if let user = result.value?.user {
						do {
							let mainContextObject = try user.toMainContext(object: user)
							CoreDataManager.shared.saveContext()
							loginResult.value?.user = mainContextObject
						} catch {
							sink.send(error: error as NSError)
						}
					}
					self.favoritesFetcher.startFetching { hasMoreDataToLoad, objects, resourceFetcher, error in
						objects.forEach { FavoritedPropertiesManager.shared.add($0) }
						sink.send(value: loginResult.value!)
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
