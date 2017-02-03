//
//  StoreApiClient.swift
//  RiteAid
//
//  Created by Manish Ahuja on 08/06/16.
//  Copyright © 2016 Fueled. All rights reserved.
//

import Foundation

class StoreApiClient: BaseAPIClient {

	static let sharedClient = StoreApiClient(baseURL: Configuration.StoreLocatorBaseURL)
	override func willEncodeRequest(request: NSMutableURLRequest) {
		request.setValue(Configuration.requestHeader, forHTTPHeaderField: "UserName")
	}

	override func handleErrorResponse(response: [String: AnyObject], errorCode: Int) -> APIError {
		if let error = response["error"] as? String {
			return APIError.BadStatusCode(statusCode: errorCode, message: error)
		}
		return APIError.InvalidRequest
	}
}
