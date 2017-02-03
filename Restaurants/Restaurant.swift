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
		if let venue = data["venue"] as? [String: Any], let name = venue["name"] as? String {
			self.name = name
		}
//		
//		if let plentiAppVirtualCardUri = data["plenti_app_virtual_card_uri"] as? String {
//			self.plentiAppVirtualCardUri = plentiAppVirtualCardUri
//		}
//		if let plentiAppStoreUrl = data["plenti_app_store_url"] as? String {
//			self.plentiAppStoreUrl = plentiAppStoreUrl
//		}
//		if let message = data["message"] as? String {
//			self.message = message
//		}
//		if let appDisabled = data["app_disabled"] as? String {
//			self.appDisabled = appDisabled == "Y"
//		}
//		
//		if let connectWellnessPlentiURL = data["plentiquicklinks_url"] as? String {
//			self.connectWellnessPlentiURL = connectWellnessPlentiURL
//		}
//		
//		if let finishLinkingPlentiURL = data["plenti_mobile_site_url"] as? String {
//			self.finishLinkingPlentiURL = finishLinkingPlentiURL
//		}
	}
}
