//
//  BaseHttpClient.swift
//  RiteAid
//
//  Created by Manish Ahuja on 08/03/16.
//  Copyright © 2016 Fueled. All rights reserved.
//

import UIKit
import Alamofire
import PromiseKit

protocol CancellableRequest: class {
	func cancel()
}

protocol DataConvertible {
	var dataRepresentation: Data { get }
}

extension Alamofire.Request: CancellableRequest {
	
}

/**
*  Abstraction layer around Alamofire.
*/
class BaseAPIClient {
	private var baseURL: String
	
	enum Method {
		case get
		case put
		case post
		case patch
		case delete
		
		func toAFMethod() -> Alamofire.HTTPMethod {
			switch self {
			case .get:
				return Alamofire.HTTPMethod.get
			case .put:
				return Alamofire.HTTPMethod.put
			case .post:
				return Alamofire.HTTPMethod.post
			case .patch:
				return Alamofire.HTTPMethod.patch
			case .delete:
				return Alamofire.HTTPMethod.delete
			}
		}
	}
	
	enum APIError: Error {
		case InvalidRequest
		case RequestFailed(message: String?)
		case InternetUnreachable
		case UserNotAuthenticated
		case InvalidResponse
		case NotImplementedYet
		case BadStatusCode(statusCode: Int, message: String?)
		case EmailAlreadyExists
		case LocationAccessDenied
		case LocationServicesDisabled
	}
	
	struct MultipartBodyPart {
		var name: String
		var data: DataConvertible
		var fileName: String?
		var mimeType: String?
		
		init(name: String, data: DataConvertible) {
			self.name = name
			self.data = data
		}
		
		init(name: String, data: DataConvertible, fileName: String?, mimeType: String?) {
			self.name = name
			self.data = data
			self.fileName = fileName
			self.mimeType = mimeType
		}
	}
	
	init(baseURL: String) {
		self.baseURL = baseURL
	}
	
	func GET(path: String, parameters: [String: AnyObject]? = nil) -> Promise<AnyObject?> {
		return self.doRequest(method: .get, path: path, parameters: parameters).promise
	}
	
	func POST(path: String, parameters: [String: AnyObject]? = nil) -> Promise<AnyObject?> {
		return self.doRequest(method: .post, path: path, parameters: parameters).promise
	}
	
	func DELETE(path: String, parameters: [String: AnyObject]? = nil) -> Promise<AnyObject?> {
		return self.doRequest(method: .delete, path: path, parameters: parameters).promise
	}
	
	func PUT(path: String, parameters: [String: AnyObject]? = nil) -> Promise<AnyObject?> {
		return self.doRequest(method: .put, path: path, parameters: parameters).promise
	}
	
	func PATCH(path: String, parameters: [String: AnyObject]? = nil) -> Promise<AnyObject?> {
		return self.doRequest(method: .patch, path: path, parameters: parameters).promise
	}
	
	func cancellableGET(path: String, parameters: [String: AnyObject]? = nil) -> (promise: Promise<AnyObject?>, request: CancellableRequest) {
		return self.doRequest(method: .get, path: path, parameters: parameters)
	}
	
	func cancellablePOST(path: String, parameters: [String: AnyObject]? = nil) -> (promise: Promise<AnyObject?>, request: CancellableRequest) {
		return self.doRequest(method: .post, path: path, parameters: parameters)
	}
	
	func cancellableDELETE(path: String, parameters: [String: AnyObject]? = nil) -> (promise: Promise<AnyObject?>, request: CancellableRequest) {
		return self.doRequest(method: .delete, path: path, parameters: parameters)
	}
	
	func cancellablePUT(path: String, parameters: [String: AnyObject]? = nil) -> (promise: Promise<AnyObject?>, request: CancellableRequest) {
		return self.doRequest(method: .put, path: path, parameters: parameters)
	}
	
	func cancellablePATCH(path: String, parameters: [String: AnyObject]? = nil) -> (promise: Promise<AnyObject?>, request: CancellableRequest) {
		return self.doRequest(method: .patch, path: path, parameters: parameters)
	}
	
	func uploadMultipartData(path: String, parameter: MultipartBodyPart) -> Promise<AnyObject?> {
		return self.uploadMultipartData(path: path, parameters: [parameter])
	}
	
	func uploadMultipartData(path: String, parameters: [MultipartBodyPart]) -> Promise<AnyObject?> {
		let request = requestForMethod(method: .post, path: path)
		return Promise { fulfill, reject in
			Alamofire.upload(multipartFormData: { multipartFormData in
				for row in parameters {
					if let mimeType = row.mimeType {
						multipartFormData.append(row.data.dataRepresentation, withName: row.name, fileName: row.fileName ?? row.name, mimeType: mimeType)
					} else {
						multipartFormData.append(row.data.dataRepresentation, withName: row.name)
					}
				}
			},
			                 usingThreshold: SessionManager.multipartFormDataEncodingMemoryThreshold,
			                 with: request,
			                 encodingCompletion: { result in
								switch result {
								case .success(let request, _, _):
									self.handleRequestResponse(methodName: "", path, request).promise.then { (value) -> Void in
										fulfill(value)
										}.catch { error in
											reject(error)
									}
								case .failure(let error):
									reject(error)
								}
			})
		}
	}
	
	private func queryComponents(key: String, _ value: AnyObject) -> [(String, String)] {
		var components: [(String, String)] = []
		if let dictionary = value as? [String: AnyObject] {
			for (nestedKey, value) in dictionary {
				components += queryComponents(key: "\(key)[\(nestedKey)]", value)
			}
		} else if let array = value as? [AnyObject] {
			for value in array {
				components += queryComponents(key: "\(key)[]", value)
			}
		} else {
			components.append(contentsOf: [(escape(string: key), escape(string: "\(value)"))])
		}
		
		return components
	}
	
	private func escape(string: String) -> String {
		let legalURLCharactersToBeEscaped = ":/?&=;+!@#$()',*"
		let legalCharacterSet = CharacterSet(charactersIn: legalURLCharactersToBeEscaped)
		return string.addingPercentEncoding(withAllowedCharacters: legalCharacterSet)!
	}
	
	private func doRequest(method: Method,
	                       path: String,
	                       parameters: [String: AnyObject]? = nil) -> (promise: Promise<AnyObject?>, request: CancellableRequest) {
		
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
		let request = requestForMethod(method: method, path: path, parameters: parameters)
		
		var methodName: String
		switch method {
		case .get:
			methodName = "GET"
		case .post:
			methodName = "POST"
		case .put:
			methodName = "PUT"
		case .delete:
			methodName = "DELETE"
		default:
			methodName = "[UNKNOWN]"
		}
		debugPrint("\(methodName) \(path)")
		if method == .get {
			var parametersString: String?
			if let parameters = parameters {
				var components: [(String, String)] = []
				for key in Array(parameters.keys).sorted(by: <) {
					let value: AnyObject! = parameters[key]
					components += self.queryComponents(key: key, value)
				}
				parametersString = components.map { "\($0)=\($1)" } .joined(separator: "&")
			} else {
				parametersString = ""
			}
			
			if let parametersString = parametersString, !parametersString.isEmpty {
				debugPrint("\(parametersString.removingPercentEncoding)")
			}
		} else {
			var parametersString: String?
			if let parameters = parameters {
				do {
					let data = try JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions.prettyPrinted)
					parametersString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as String?
				} catch {
					parametersString = "(not JSON)"
				}
			}
			let parameters = parametersString ?? "(empty)"
			debugPrint("JSON: \(parameters.removingPercentEncoding)")
		}
		let alamoFireRequest = Alamofire.request(request as URLRequestConvertible)
		return self.handleRequestResponse(methodName: methodName, path, alamoFireRequest)
	}
	
	func willEncodeRequest(request: NSMutableURLRequest) {
		debugPrint("Encoded Request: \(request)")
	}
	
	func didEncodeRequest(request: URLRequest) {
		debugPrint("decoded Request: \(request)")
	}
	
	func handleErrorResponse(response: [String: AnyObject], errorCode: Int) -> APIError {
		return APIError.NotImplementedYet
	}
	
	private func requestForMethod(method: Method, path: String, parameters: [String: AnyObject]? = nil) -> URLRequest {
		let mutableURLRequest = NSMutableURLRequest(url: URL(string: self.baseURL + path)!)
		mutableURLRequest.httpMethod = method.toAFMethod().rawValue
		self.willEncodeRequest(request: mutableURLRequest)
		let encoding: ParameterEncoding = method == .get ? URLEncoding.httpBody : JSONEncoding.default
		let dataRequest: DataRequest = Alamofire.request(path, method: method.toAFMethod(), parameters: parameters, encoding: encoding, headers: nil)
		self.didEncodeRequest(request: dataRequest.request!)
		return dataRequest.request!
	}

	private func handleRequestResponse(methodName: String, _ path: String, _ request: DataRequest) -> (promise: Promise<AnyObject?>, request: CancellableRequest) {
		return (
			promise: Promise { fulfill, reject in
				request.responseJSON { response in
					UIApplication.shared.isNetworkActivityIndicatorVisible = false
					print("Response received \(methodName) \(path)")
					if let error = response.result.error {
							reject(APIError.BadStatusCode(statusCode: response.response?.statusCode ?? 0, message: error.localizedDescription))
					} else {
						print("Returned JSON \(response.result.value)")
						if let httpResponse = response.response {
							if httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299 {
								fulfill(response.result.value as AnyObject?)
							} else if let responseResultDictionary = response.result.value as? [String: AnyObject] {
								if let error = responseResultDictionary["error"] as? String {
									reject(APIError.BadStatusCode(statusCode: httpResponse.statusCode, message: error))
								} else {
									let apiError = self.handleErrorResponse(response: responseResultDictionary, errorCode: httpResponse.statusCode)
									reject(apiError)
								}
							}
						} else {
							fulfill(response.result.value as AnyObject?)
						}
					}
				}
			},
			request: request
		)
	}
}
