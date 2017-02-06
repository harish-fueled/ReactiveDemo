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
	
	fileprivate var dataSource = [Restaurant]()
	var viewModel = RestaurantsViewModel()
	var disposable = CompositeDisposable()

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
		self.disposable += self.viewModel.fetchFoursquareRestaurants().on(failed: { error in
			print("Failed fetching restaurants : \(error)")
			}, value: { [weak self] response in
				self?.dataSource = response
				self?.tableView.reloadData()
		}).start()
	}
}

extension RestaurantsViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return dataSource.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: RestaurantTableViewCell.identifier, for: indexPath) as! RestaurantTableViewCell
		let restaurant = dataSource[indexPath.row]
		cell.configure(restaurant: restaurant)
		return cell
	}
}

extension RestaurantsViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let restaurant = dataSource[indexPath.row]
		print("Selected Restaurant : \(restaurant)")
	}
}
