//
//  FunctionTransformations.swift
//  HoneyBee
//
//  Created by Alex Lynch on 12/13/19.
//  Copyright © 2019 IAM Apps. All rights reserved.
//

import Foundation

func elevate(_ function: @escaping (@escaping (Error?)->Void ) -> Void) -> (@escaping (FailableResult<Void>) -> Void) -> Void {
    return {(callback: @escaping ((FailableResult<Void>) -> Void)) in
        function { error in
            if let error = error {
                callback(.failure(error))
            } else {
                callback(.success(Void()))
            }
        }
    }
}

func elevate<C>(_ function: @escaping (@escaping (C?, Error?)->Void ) -> Void) -> (@escaping (FailableResult<C>) -> Void) -> Void {
    return {(callback: @escaping ((FailableResult<C>) -> Void)) in
        function { c, error in
            if let error = error {
                callback(.failure(error))
            } else if let c = c {
                callback(.success(c))
            } else {
                callback(.failure(NSError(domain: "Completion called with two nil values.", code: -99, userInfo: nil)))
            }
        }
    }
}

func populateVoid<T>(failableResult: FailableResult<Void>, with t: T) -> FailableResult<T> {
    switch failableResult {
    case let .failure(error):
        return .failure(error)
    case .success():
        return .success(t)
    }
}

func elevate<C>(_ function: @escaping (@escaping (Error?, C?)->Void ) -> Void) -> (@escaping (FailableResult<C>) -> Void) -> Void {
    elevate { (callback: @escaping (C?, Error?) -> Void) in
        function { (error, c) in
            callback(c, error)
        }
    }
}

func elevate<T>(_ function: @escaping (T) -> (@escaping (Error?) -> Void) -> Void) -> (T, @escaping (FailableResult<T>) -> Void) -> Void {
    return { (t: T, callback: @escaping (FailableResult<T>) -> Void) -> Void in
        elevate(function(t))({ result in
            callback(populateVoid(failableResult: result, with: t))
        })
    }
}

func elevate<T>(_ function: @escaping (T, @escaping (Error?) -> Void) -> Void) -> (T, @escaping (FailableResult<T>) -> Void) -> Void {
    return { (t: T, callback: @escaping (FailableResult<T>) -> Void) -> Void in
        elevate(function =<< t)({ result in
            callback(populateVoid(failableResult: result, with: t))
        })
    }
}

func elevate<T>(_ function: @escaping (@escaping (Error?) -> Void) -> Void) -> (T, @escaping (FailableResult<T>) -> Void) -> Void {
    return { (t: T, callback: @escaping (FailableResult<T>) -> Void) -> Void in
        elevate(function)({ result in
            callback(populateVoid(failableResult: result, with: t))
        })
    }
}

func elevate(_ function: @escaping (@escaping () -> Void) throws -> Void) -> (@escaping (FailableResult<Void>) -> Void) -> Void {
    return { (callback: @escaping (FailableResult<Void>) -> Void) -> Void in
        do {
            try function {
                callback(.success(Void()))
            }
        } catch {
            callback(.failure(error))
        }
    }
}

func elevate<C>(_ function: @escaping () throws -> C) -> (@escaping (FailableResult<C>) -> Void) -> Void {
    return { (callback: @escaping (FailableResult<C>) -> Void) -> Void in
        do {
            try callback(.success(function()))
        } catch {
            callback(.failure(error))
        }
    }
}


func elevate<T, C>(_ function: @escaping (T, @escaping (C?, Error?) -> Void) -> Void) -> (T, @escaping (FailableResult<C>) -> Void) -> Void {
    return { (t: T, callback: @escaping (FailableResult<C>) -> Void) -> Void in
        elevate(bind(function, t))(callback)
    }
}

func elevate<C>(_ function: @escaping (@escaping (C) -> Void) throws -> Void) -> (@escaping (FailableResult<C>) -> Void) -> Void {
    return { (callback: @escaping (FailableResult<C>) -> Void) -> Void in
        do {
            try function { result in
                callback(.success(result))
            }
        } catch {
            callback(.failure(error))
        }
    }
}

func elevate<T, C>(_ function: @escaping (T) -> (@escaping (C?, Error?) -> Void) -> Void) -> (T, @escaping (FailableResult<C>) -> Void) -> Void {
    return { (t: T, callback: @escaping (FailableResult<C>) -> Void) -> Void in
        elevate(function(t))(callback)
    }
}
