//
//  APIInterface.swift
//  Owners
//
//  Created by Ankit on 16/05/16.
//  Copyright © 2016 Fueled. All rights reserved.
//

import ReactiveSwift
import Alamofire
import SwiftyJSON
import CoreData

extension Request {
	public func debugLog() -> Self {
		#if DEBUG
			debugPrint(self)
		#endif
		return self
	}
}

class APIInterface {
	struct Constant {
		static let timeoutIntervalForRequest = 30.0
	}
	static let shared = APIInterface()
	fileprivate var disposable = CompositeDisposable()
	
	lazy var manager: SessionManager = {
		let configuration = URLSessionConfiguration.default
		configuration.timeoutIntervalForRequest = Constant.timeoutIntervalForRequest
		return Alamofire.SessionManager(configuration: configuration)
	}()
	
	var genericError: NSError = {
		return NSError(domain: "api.owners.com", code: -1, userInfo: [NSLocalizedDescriptionKey: "DefaultErrorMessage"])
	}()
	
	init() {
		
	}
	
	deinit {
		self.disposable.dispose()
	}
	
	fileprivate func interceptCookies() {
		let jar = HTTPCookieStorage.shared
		if let cookies = jar.cookies {
			for cookie in cookies {
				jar.setCookie(cookie)
			}
		}
	}
	
	fileprivate func request<T: JSONParsing>(_ route: APIRouter) -> SignalProducer<T, NSError> {
		let request = self.writeRequest(with: route)
		return request.flatMap(.latest, transform: requestProducer)
	}
	
	fileprivate func requestProducer<T: JSONParsing>(_ request: DataRequest) -> SignalProducer<T, NSError> {
		return SignalProducer { (observer, disposable) in
			DispatchQueue.global(qos: .background).async {
				request.debugLog().responseString(completionHandler: { [weak self] response in
					DispatchQueue.global(qos: .background).async {
						let context = CoreDataManager.shared.backgroundManagedObjectContext
						
						if case Result.failure(_) = response.result {
							self?.parseError(with: response.data, context, observer)
							return
						}
						if let responseString = response.result.value,
							let data = responseString.data(using: .utf8)
						{
							self?.interceptCookies()
							self?.parse(data as AnyObject?, context: context, observer)
						} else {
							self?.parseError(with: response.data, context, observer)
						}
					}
				})
			}
		}
	}
	
	fileprivate func writeRequest(with route: APIRouter) -> SignalProducer<DataRequest, NSError> {
		return SignalProducer { (observer, disposable) in
			if !route.isMultipart {
				observer.send(value: self.manager.request(route))
				observer.sendCompleted()
			} else {
				do {
					Alamofire.upload(multipartFormData: { multipartFormData in
						self.addParameters(route.params, toMultipartFormData: multipartFormData)
					}, to: try route.asURLRequest().url!, encodingCompletion: {
						switch $0 {
						case .success(let request, _, _) :
							observer.send(value: request)
							observer.sendCompleted()
						case .failure(_) :
							let errorDomain = "JSONParsing"
							let desc = "JSON value type mismatch at key path"
							let error = NSError(domain: errorDomain, code: (-3), userInfo: [NSLocalizedDescriptionKey: desc])
							observer.send(error: error)
						}
					})
				} catch {
					observer.send(error: error as NSError)
				}
			}
		}.observe(on: UIScheduler())
	}
	
	fileprivate func addParameters(_ parameters: [String: Any], toMultipartFormData multipart: MultipartFormData) {
		for parameter in parameters {
			if let image = parameter.1 as? UIImage, let data = UIImagePNGRepresentation(image) {
				multipart.append(data, withName: parameter.0, fileName: "profile", mimeType: "image/png")
			} else if let string = parameter.1 as? String {
				multipart.append(string.data(using: String.Encoding.utf8)!, withName: parameter.0)
			} else if var int = parameter.1 as? Int {
				multipart.append(Data(bytes: &int, count: MemoryLayout<Int>.size), withName: parameter.0)
			}
		}
	}

	fileprivate func parseError<T: JSONParsing>(with data: Data?, _ context: NSManagedObjectContext, _ sink: Observer<T, NSError>) {
		guard let data = data else {
			sink.send(error: self.genericError)
			return
		}
		do {
			let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
			
			ErrorResponse.parse(json: JSON(json), context: context, completionBlock: { (errorResponse, error) -> Void in
				let errorMessage = (errorResponse?.message)!
				let localError = (NSError(domain: (errorResponse?.domain)!, code: -1,
					userInfo: [NSLocalizedDescriptionKey: errorMessage]))
				sink.send(error: localError)
			})
		} catch _ {
			sink.send(error: self.genericError)
		}
	}

	fileprivate func parse<T: JSONParsing>(_ object: AnyObject?, context: NSManagedObjectContext, _ sink: Observer<T, NSError>) {
		if let object = object {
			let json = JSON(data: object as! Data)
		
			T.parse(json: json, context: context, completionBlock: { (object, error) -> Void in
				if let error = error {
					sink.send(error: error)
				} else {
					if let object = object {
						DispatchQueue.main.async {
							do {
								CoreDataManager.shared.saveContext()
								let mainContextObject = try object.toMainContext(object: object)
								sink.send(value: mainContextObject)
								sink.sendCompleted()
							} catch {
								sink.send(error: error as NSError)
							}
						}
					}
				}
			})
		} else {
			let errorDomain = "JSONParsing"
			let desc = "JSON value type mismatch at key path"
			let error = NSError(domain: errorDomain, code: (-3), userInfo: [NSLocalizedDescriptionKey: desc])
			sink.send(error: error)
		}
	}
}

extension APIInterface {
	
	func fetchFoursquareRestaurants() -> SignalProducer<FoursquareRestaurantsResponse, NSError> {
		let params = ["client_id": "5AYW35NKNLOX3RQTSRUXBXLBF5IA1DJHWNZXC4KPHV1XZ4W4",
		              "client_secret": "X1BBQH5YDRZSRGJS3G5U5EVKUKTPZXKDXIENXTVINABGXPOL",
		              "v": "20161215",
		              "ll": "28.535516,77.391026",
		              "section": "food",
		              "limit": "50",
		              "sortByDistance": "1"]
		return self.request(APIRouter.fetchFoursquareVenues(params: params))
	}
}
