//
//  RestaurantTableViewCell.swift
//  Restaurants
//
//  Created by Harish Saini on 02/02/17.
//  Copyright © 2017 Fueled. All rights reserved.
//

import UIKit

class RestaurantTableViewCell: UITableViewCell {
	static var identifier = "RestaurantTableViewCellIdentifier"

	@IBOutlet weak var titleLabel: UILabel!
	
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
	
	func configure(restaurantVieModel: RestaurantViewModel) {
		titleLabel.text = restaurantVieModel.name.capitalized
	}
}
