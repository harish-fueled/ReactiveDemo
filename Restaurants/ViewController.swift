//
//  ViewController.swift
//  Restaurants
//
//  Created by Harish Saini on 02/02/17.
//  Copyright © 2017 Fueled. All rights reserved.
//

import UIKit
//
//let listUrlString =  "https://api.foursquare.com/v2/venues/explore?client_id=5AYW35NKNLOX3RQTSRUXBXLBF5IA1DJHWNZXC4KPHV1XZ4W4&client_secret=X1BBQH5YDRZSRGJS3G5U5EVKUKTPZXKDXIENXTVINABGXPOL&v=20130815&ll=28.535516,77.391026&section=food&limit=50&sortByDistance=1"
//let myUrl = NSURL(string: listUrlString);
//let request: NSMutableURLRequest = NSMutableURLRequest()
//request.URL = myUrl
//request.HTTPMethod = "GET"
//request.cachePolicy = NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData
//request.setValue("application/json", forHTTPHeaderField: "Content-Type")


class ViewController: UIViewController {

	@IBOutlet weak var tableView: UITableView!
	
	fileprivate var dataSource = ["test", "test", "test", "test", "test", "test", "test", "test"]
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
		configureTableView()
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
