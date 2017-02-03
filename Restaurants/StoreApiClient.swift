//
//
//  Created by Manish Ahuja on 08/06/16.
//  Copyright © 2016 Fueled. All rights reserved.
//

import Foundation

class StoreApiClient: BaseAPIClient {

	static let sharedClient = StoreApiClient(baseURL: Configuration.FourSquareBaseURL)
	override func willEncodeRequest(request: inout URLRequest) {
		
	}

	override func handleErrorResponse(response: [String: Any], errorCode: Int) -> APIError {
		if let error = response["error"] as? String {
			return APIError.BadStatusCode(statusCode: errorCode, message: error)
		}
		return APIError.InvalidRequest
	}
}
