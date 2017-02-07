//
//  ViewController.swift
//  Restaurants
//
//  Created by Harish Saini on 02/02/17.
//  Copyright © 2017 Fueled. All rights reserved.
//

import UIKit
import ReactiveSwift

class RestaurantsViewController: UIViewController {
	
	@IBOutlet weak var tableView: UITableView!
	
	var disposable = CompositeDisposable()
	var viewModels: MutableProperty<[RestaurantViewModel]?> = MutableProperty(nil)
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		configureTableView()
		fetchFoursquareRestaurants()
	}
	
	private func configureTableView() {
		tableView.dataSource = self
		tableView.delegate = self
	}
	
	func fetchFoursquareRestaurants() {
		APIInterface.shared.fetchFoursquareRestaurants().startWithResult { [weak self]result in
			if let error = result.error {
				print("error occurred \(error)")
			} else if let restaurants = result.value?.restaurants {
				self?.viewModels.value = restaurants.map { RestaurantViewModel(restaurant: $0) }
				self?.tableView.reloadData()
			}
		}
	}
}

extension RestaurantsViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return viewModels.value?.count ?? 0
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: RestaurantTableViewCell.identifier, for: indexPath) as! RestaurantTableViewCell
		let restaurantViewModel = viewModels.value?[indexPath.row]
		cell.configure(restaurantVieModel: restaurantViewModel!)
		return cell
	}
}

extension RestaurantsViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let restaurantViewModel = viewModels.value?[indexPath.row]
		print("Selected Restaurant : \(restaurantViewModel!.name)")
	}
}
