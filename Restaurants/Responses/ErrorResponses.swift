//
//  ErrorResponses.swift
//  Owners
//
//  Created by Ankit on 16/05/16.
//  Copyright © 2016 Fueled. All rights reserved.
//

import Foundation
import SwiftyJSON
import ReactiveSwift
import CoreData

final class ErrorResponse: NSObject {
	var domain = ""
	var message = ""
	var field: String?
	
	init(domain: String, message: String, field: String?) {
		self.domain = domain
		self.message = message
		self.field = field
	}
}

extension ErrorResponse: JSONParsing {
	internal static func parse(json: JSON, context: NSManagedObjectContext, completionBlock: (@escaping (ErrorResponse?, NSError?) -> Void)) {
		let resultJson = json["result"]
		
		if let errors = resultJson["errors"].array, !errors.isEmpty {
			let message = errors.first!["detail"].stringValue
			let field = errors.first!["code"].stringValue
			let domain = resultJson["errorId"].string ?? "defaultId"
			
			let errorObject = ErrorResponse (
				domain: domain,
				message: message,
				field: field
			)
			completionBlock(errorObject, nil)
		} else {
			completionBlock(ErrorResponse.init(domain: "", message: "Unknown Error", field: nil), nil)
		}
	}
}
