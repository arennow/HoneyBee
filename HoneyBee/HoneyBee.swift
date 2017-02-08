//
//  HoneyBee.swift
//  HoneyBee
//
//  Created by Alex Lynch on 2/8/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import Foundation

public struct HoneyBee {
	public static func start(on queue: DispatchQueue = DispatchQueue.global(), _ defineBlock: @escaping (ProcessLink<Void, Void>) -> Void) {
		self.start(with: Void(), on: queue, defineBlock)
	}
	
	public static func start<A>(with arg: A, on queue: DispatchQueue = DispatchQueue.global(), _ defineBlock: @escaping (ProcessLink<A, A>) -> Void) {
		// access control
		guard let bundleID = Bundle.main.bundleIdentifier else {
			preconditionFailure("Bundle ID must be present")
		}
		
		guard let value = Bundle.main.infoDictionary?["HoneyBeeAccessKey"] else {
			preconditionFailure("No HoneyBeeAccessKey found in main bundle info plist")
		}
		
		var candidates:[String] = []
		
		if let string = value as? String {
			candidates.append(string)
		}
		if let array = value as? [String] {
			candidates.append(contentsOf: array)
		}
		
		let combined = bundleID.components(separatedBy: ".").joined()
		let altered = String(combined.characters.map({
			let s = String($0)
			return ["a","e","i","o","u"].contains(s) ? s.uppercased() : s
		}).joined().characters.reversed()).sha256()
		
		if candidates.first(where: { $0 == altered }) == nil {
			preconditionFailure("Invalid HoneyBeeAccessKey")
		}
		
		// the real work
		let root = ProcessLink<A, A>(function: {a, block in block(a)}, queue: queue)
		queue.async {
			defineBlock(root)
			root.execute(argument: arg, completion: {})
		}
	}
}
