//
//  JSONParser.swift
//  Owners
//
//  Created by Ankit on 16/05/16.
//  Copyright © 2016 Fueled. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreData

protocol JSONParsing {
	static func parse(json: JSON, context: NSManagedObjectContext, completionBlock: @escaping ((Self?, NSError?) -> Void))
	func toMainContext(object: Self) throws -> Self
}

enum ParsingErrors: Error {
	case invalidObject
}

extension JSONParsing {
	func toMainContext(object: Self) throws -> Self {
		return object
	}
}

protocol ListProtocol {
	static func jsonList(json: JSON) -> JSON
}

// Operator will set passed value only if it exists, nil won't be set to property
precedencegroup PassedValueIfExists {
	associativity: left
	higherThan: AdditionPrecedence
}

infix operator =^ : PassedValueIfExists

// Operator will set passed value if it exists and not empty (String), nil won't be set to property
precedencegroup PassedValueIfExistsNotEmpty {
	associativity: left
	higherThan: AdditionPrecedence
}

infix operator ==^ : PassedValueIfExistsNotEmpty

func =^ <T> (property: inout T?, newValue: T?) {
	if let value = newValue {
		property = value
	}
}

func =^ <T> (property: inout T, newValue: T?) {
	if let value = newValue {
		property = value
	}
}

func ==^ (property: inout String?, newValue: String?) {
	if let value = newValue, !value.characters.isEmpty {
		property = value
	}
}
