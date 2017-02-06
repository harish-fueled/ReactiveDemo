//
//  APIRouter.swift
//  Owners
//
//  Created by Ankit on 16/05/16.
//  Copyright © 2016 Fueled. All rights reserved.
//

import Alamofire

enum APIRouter: URLRequestConvertible {
	case fetchFoursquareVenues(params: [String: String])
	
	var method: Alamofire.HTTPMethod {
		return .get
	}
	
	var baseURL: String {
		return Configuration.FourSquareBaseURL
	}
	
	var path: String {
		switch self {
		case .fetchFoursquareVenues:
			return "venues/explore"
		}
	}
	var params: [String: Any] {
		switch self {
		case .fetchFoursquareVenues(let params):
			return params
		}
	}
	var URL: Foundation.URL {
		let baseURL = Foundation.URL(string: self.baseURL)!
		return baseURL.appendingPathComponent(path)
	}
	
	var isMultipart: Bool {
		return false
	}
	
	func asURLRequest() throws -> URLRequest {
		var mutableURLRequest = URLRequest(url: self.URL)
		mutableURLRequest.httpMethod = method.rawValue
		
		let acceptType = "application/json"
		
		mutableURLRequest.setValue(acceptType, forHTTPHeaderField: APIKeys.Accept)
		mutableURLRequest.setValue(acceptType, forHTTPHeaderField: APIKeys.RequestContentType)
		
		var parameters: [String: Any]?
		if method == .post || method == .put || method == .delete {
			do {
				mutableURLRequest.httpBody = try JSONSerialization.data(withJSONObject: params, options: JSONSerialization.WritingOptions())
			} catch {
				print("APIRouter: error while creating url request")
			}
		} else {
			parameters = self.params
		}
		return try URLEncoding().encode(mutableURLRequest as URLRequestConvertible, with: parameters)
	}
}
