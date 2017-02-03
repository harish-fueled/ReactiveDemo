//
//  ViewController.swift
//  Restaurants
//
//  Created by Harish Saini on 02/02/17.
//  Copyright © 2017 Fueled. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet weak var tableView: UITableView!
	
	fileprivate var dataSource = ["test", "test", "test", "test", "test", "test", "test", "test"]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		configureTableView()
		let _ = Venue.fetchFoursquareVenues().then { result -> Void in
			if result == "error" {
				print("error")
			} else {
				print("stores fetched")
			}
		}
	}
	
	private func configureTableView() {
		tableView.dataSource = self
		tableView.delegate = self
	}
}

extension ViewController: UITableViewDataSource {
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

extension ViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let restaurant = dataSource[indexPath.row]
		print("Selected Restaurant : \(restaurant)")
	}
}
