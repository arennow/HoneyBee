//
//  MultiPathTests.swift
//  HoneyBeeTests
//
//  Created by Alex Lynch on 10/22/17.
//  Copyright © 2017 IAM Apps. All rights reserved.
//

import XCTest
@testable import HoneyBee

fileprivate extension Link {
    func wait(seconds: UInt32) -> Link<B, Performer> {
        self.tunnel { (link: Link<B, Performer>) in
            link.drop.chain(sleep =<< seconds)
        }
    }
}

class MultiPathTests: XCTestCase {
	let funcContainer = TestingFunctions()
	
	override func setUp() {
		super.setUp()
		
		HoneyBee.functionOvercallResponse = .fail
		HoneyBee.functionUndercallResponse = .fail
		HoneyBee.internalFailureResponse = .fail
		HoneyBee.mismatchedConjoinResponse = .fail
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
	
	func testBranch() {
		let expect1 = expectation(description: "First branch should be reached")
		let expect2 = expectation(description: "Second branch should be reached")
		
        let assertEquals = async2(assertEquals(t1: t2:)) as DoubleArgFunction<Int, Int, Void>
		
		let async = HoneyBee.start()
            
        let string = self.funcContainer.intToString(async)(10)
        let int = self.funcContainer.stringToInt(string)
        
        let eq1 = assertEquals(t1: int)(t2: 10)
        expect1.fulfill(eq1.drop)
            
        let doubleInt = self.funcContainer.multiplyInt(int)
        let eq2 = assertEquals(t1: doubleInt)(t2: 20)
        expect2.fulfill(eq2)

        eq2.error(fail)
        
		waitForExpectations(timeout: 1) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
    func testBranchWithInsert() {
        let expect1 = expectation(description: "First branch should be reached")
        let expect2 = expectation(description: "Second branch should be reached")
        
        let assertEquals = async2(assertEquals(t1: t2:)) as DoubleArgFunction<Int, Int, Void>
        
        let async = HoneyBee.start()
        let asynFuncs = async.insert(self.funcContainer)
            
        let string = asynFuncs.intToString(10)
        let int = asynFuncs.stringToInt(string)
        
        let eq1 = assertEquals(t1: int)(t2: 10)
        expect1.fulfill(eq1.drop)
            
        let doubleInt = asynFuncs.multiplyInt(int)
        let eq2 = assertEquals(t1: doubleInt)(t2: 20)
        expect2.fulfill(eq2.drop)

        eq2.error(fail)
        
        waitForExpectations(timeout: 1) { error in
            if let error = error {
                XCTFail("waitForExpectationsWithTimeout errored: \(error)")
            }
        }
    }
    
	func testCompoundJoin() {
		let expectA = expectation(description: "Join should be reached, path A")
		
		func compoundMethod(int: Int, string: String, int2: Int) {
			expectA.fulfill()
		}
		
		let async = HoneyBee.start()
        
        async.branch { stem in
            self.funcContainer.constantInt(stem)
            +
            self.funcContainer.constantString(stem)
            +
            self.funcContainer.constantInt(stem)
        }
        .chain(compoundMethod)
        .error(fail)
			
		waitForExpectations(timeout: 1) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testJoin() {
        
		let expectA = expectation(description: "Join should be reached, path A")
		let expectB = expectation(description: "Join should be reached, path B")
		
        func assertEquals<T: Equatable>() -> DoubleArgFunction<T, T, Void> {
            async2(assertEquals(t1: t2:)) as DoubleArgFunction<T, T, Void>
        }
        
		let sleepTime:UInt32 = 1
		
        do {
            let async = HoneyBee.start()
            let asyncFuncs = async.insert(self.funcContainer)
            
            let int = asyncFuncs.constantInt()
            
            let wait = asyncFuncs.wait(seconds: sleepTime)
            let string = wait.constantString()
            
            let multipled = asyncFuncs.multiplyString(string)(by: int)
            let catted = asyncFuncs.stringCat(multipled)
            
            assertEquals()(t1: catted)(t2: "lamblamblamblamblamblamblamblambcat")
                .chain(expectA.fulfill)
                .error(fail)
        }

        do {
            let async = HoneyBee.start()
            let asyncFuncs = async.insert(self.funcContainer)
                    
            let int = asyncFuncs.constantInt()
            
            let wait = asyncFuncs.wait(seconds: sleepTime)
            let string = wait.constantString()
            
            let bool = asyncFuncs.stringLengthEquals(int)(string)
            assertEquals()(bool)(false)
                .chain(expectB.fulfill)
                .error(fail)
        }
        
		waitForExpectations(timeout: 3) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testJoinLeftAndJoinRight() {
		let expectA = expectation(description: "Join should be reached, path A")
		let expectB = expectation(description: "Join should be reached, path B")
		
		let sleepTime:UInt32 = 1
		
		HoneyBee.start()
                .branch { stem -> Link<String, DefaultDispatchQueue> in
					let result1 = stem.chain(self.funcContainer.constantInt)
					
					let result2 = stem.chain(sleep =<< sleepTime).drop
										.chain(self.funcContainer.constantString)
					
					return (result2 <+ result1)
				}
				.chain(self.funcContainer.stringCat)
				.chain(assertEquals =<< "lambcat")
				.chain(expectA.fulfill)
                .error(fail)
		
		HoneyBee.start()
                .branch { stem in
					let result1 = stem.chain(self.funcContainer.constantInt)
					
					let result2:Link<String, DefaultDispatchQueue> = stem.chain(sleep =<< sleepTime)
						.insert(self.funcContainer)
						.chain(TestingFunctions.constantString)
					
					return (result1 +> result2)
				}
				.chain(assertEquals =<< "lamb")
				.chain(expectB.fulfill)
                .error(fail)

		waitForExpectations(timeout: 3) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testMap() {
		var intsToExpectations:[Int:XCTestExpectation] = [:]
		
		let source = Array(0..<10)
		for int in source {
			intsToExpectations[int] = expectation(description: "Expected to map value for \(int)")
		}
		
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		
		HoneyBee.start()
                .insert(source)
				.map { elem in
					elem.chain(self.funcContainer.multiplyInt)
				}
				.each { elem in
					elem.chain { (int:Int) -> Void in
						let sourceValue = int/2
						if let exepct = intsToExpectations[sourceValue]  {
							exepct.fulfill()
						} else {
							XCTFail("Map source value not found \(sourceValue)")
						}
					}
				}
				.drop
				.chain(finishExpectation.fulfill)
                .error(fail)
		
		waitForExpectations(timeout: 3) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testMapWithLimit() {
		var intsToExpectations:[Int:XCTestExpectation] = [:]
		
		let source = Array(0..<10)
		for int in source {
			intsToExpectations[int] = expectation(description: "Expected to map value for \(int)")
		}
		
		let sleepSeconds = 0.1
		
		let accessCounter: AtomicInt = 0
		accessCounter.guaranteeValueAtDeinit(0)
		
		func asynchronouslyHoldLock(iteration: Int, completion: @escaping (Int)->Void) {
			if accessCounter.increment() != 1 {
				XCTFail("Countered should never != 1 at this point. Implies parallel execution. Iteration: \(iteration)")
			}
			
			DispatchQueue.global(qos: .background).async {
				sleep(UInt32(sleepSeconds))
				accessCounter.decrement()
				completion(iteration)
			}
		}
		
		
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		let elementExpectation = expectation(description: "Element should finish \(source.count) times")
		elementExpectation.expectedFulfillmentCount = source.count
		
		HoneyBee.start()
                .insert(source)
				.map(limit: 1) { elem in
					elem.tunnel { link in
						link.chain(asynchronouslyHoldLock).drop
							.chain(elementExpectation.fulfill)
					}
					.chain(self.funcContainer.multiplyInt)
				}
				.each { elem in
					elem.chain { (int:Int) -> Void in
						let sourceValue = int/2
						if let exepct = intsToExpectations[sourceValue]  {
							exepct.fulfill()
						} else {
							XCTFail("Map source value not found \(sourceValue)")
						}
					}
				}
				.drop
				.chain(finishExpectation.fulfill)
                .error(fail)
		
		waitForExpectations(timeout: TimeInterval(Double(source.count) * sleepSeconds + 2.0)) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testMapQueue() {
		let source = Array(0...10)
		
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		
		let async = HoneyBee.start(on: MainDispatchQueue())
            
        let asyncSource = async.insert(source)
            
        asyncSource.map { (elem: Link<Int, MainDispatchQueue>) -> Link<Int, MainDispatchQueue> in
            elem.chain{ (_:Int) -> Void in
                XCTAssert(Thread.current.isMainThread, "Not main thread")
            }
            return self.funcContainer.multiplyInt(elem)
        }
        .drop
        .chain(finishExpectation.fulfill)
        .error(fail)
		
		waitForExpectations(timeout: 3) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testFilter() {
		let source = Array(0...10)
		let result = [0,2,4,6,8,10]
		
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		
		HoneyBee.start()
                .insert(source)
				.filter { elem in
					elem.chain(self.funcContainer.isEven)
				}
				.chain{ XCTAssert($0 == result, "Filter failed. expected: \(result). Received: \($0).") }
				.chain(finishExpectation.fulfill)
                .error(fail)
		
		waitForExpectations(timeout: 3) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testFilterWithLimit() {
		let source = Array(0...10)
		let result = [0,2,4,6,8,10]
		
		let sleepSeconds = 0.1
		
		let accessCounter: AtomicInt = 0
		accessCounter.guaranteeValueAtDeinit(0)
		
		func asynchronouslyHoldLock(iteration: Int, completion: @escaping (Int)->Void) {
			if accessCounter.increment() != 1 {
				XCTFail("Counter should never != 1 at this point. Implies parallel execution. Iteration: \(iteration)")
			}
			
			DispatchQueue.global(qos: .background).async {
				sleep(UInt32(sleepSeconds))
				accessCounter.decrement()
				completion(iteration)
			}
		}

		
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		let elementExpectation = expectation(description: "Element should finish \(source.count) times")
		elementExpectation.expectedFulfillmentCount = source.count
		
		HoneyBee.start()
				.insert(source)
				.filter(limit: 1) { elem in
					elem.tunnel { link in
						link.chain(asynchronouslyHoldLock).drop
							.chain(elementExpectation.fulfill)
						}
						.chain(self.funcContainer.isEven)
				}
				.chain{ XCTAssert($0 == result, "Filter failed. expected: \(result). Received: \($0).") }
				.chain(finishExpectation.fulfill)
                .error(fail)
		
		waitForExpectations(timeout: TimeInterval(Double(source.count) * sleepSeconds + 2.0)) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testEach() {
		var expectations:[XCTestExpectation] = []
		var filledExpectationCount:AtomicInt = 0
		
		for int in 0..<10 {
			expectations.append(expectation(description: "Expected to evaluate \(int)"))
		}
		
		func incrementFullfilledExpectCount() {
			filledExpectationCount.increment()
		}
		
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		
		HoneyBee.start()
				.insert(expectations)
				.each { elem in
					elem.chain(XCTestExpectation.fulfill)
						.chain(incrementFullfilledExpectCount)
				}
				.drop
				.chain {
					XCTAssert(filledExpectationCount.get() == expectations.count, "All expectations should be filled by now, but was actually \(filledExpectationCount.get()) != \(expectations.count)")
				}
				.chain(finishExpectation.fulfill)
                .error(fail)
		
		waitForExpectations(timeout: 3) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testEachWithRateLimiter() {
		var expectations:[XCTestExpectation] = []
		var filledExpectationCount: AtomicInt = 0
		
		for int in 0..<10 {
			expectations.append(expectation(description: "Expected to evaluate \(int)"))
		}
		
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		
		func incrementFullfilledExpectCount() {
			filledExpectationCount.increment()
		}
		
		func assertAllExpectationsFullfilled() {
			XCTAssert(filledExpectationCount.get() == expectations.count, "All expectations should be filled by now, but was actually \(filledExpectationCount) != \(expectations.count)")
		}
		
		HoneyBee.start()
				.insert(expectations)
				.each { elem in
					elem.limit(3) { link in
						link.chain(XCTestExpectation.fulfill)
							.chain(incrementFullfilledExpectCount)
					}
				}
				.drop
				.chain(assertAllExpectationsFullfilled)
				.chain(finishExpectation.fulfill)
                .error(fail)
		
		waitForExpectations(timeout: 3) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testEachWithLimit() {
		let source = Array(0..<3)
		let sleepSeconds = 0.1
		
		let accessCounter: AtomicInt = 0
		accessCounter.guaranteeValueAtDeinit(0)
		
		func asynchronouslyHoldLock(iteration: Int, completion: @escaping (Int)->Void) {
			if accessCounter.increment() != 1 {
				XCTFail("Counter should never be != 1 at this point. Implies parallel execution. Iteration: \(iteration)")
			}
			
			DispatchQueue.global(qos: .background).async {
				sleep(UInt32(sleepSeconds))
				accessCounter.decrement()
				completion(iteration)
			}
		}
		
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		let elementExpectation = expectation(description: "Element should finish \(source.count) times")
		elementExpectation.expectedFulfillmentCount = source.count
		
		HoneyBee.start()
                .insert(source)
				.each(limit: 1) { elem in
					elem.chain(asynchronouslyHoldLock).drop
						.chain(elementExpectation.fulfill)
				}
				.drop
				.chain(finishExpectation.fulfill)
                .error(fail)
		
		waitForExpectations(timeout: TimeInterval(Double(source.count) * sleepSeconds + 2.0)) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testLimit() {
		let source = Array(0..<3)
		let sleepNanoSeconds:UInt32 = 100
		
		let accessCounter: AtomicInt = 0
		
		func asynchronouslyHoldLock(iteration: Int, completion: @escaping (Int)->Void) {
			if accessCounter.increment() != 1 {
				XCTFail("Counter should never be != 1 at this point. Implies parallel execution. Iteration: \(iteration)")
			}
			
			DispatchQueue.global(qos: .background).async {
				usleep(sleepNanoSeconds)
				accessCounter.decrement()
				completion(iteration)
			}
		}
		
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		let startParalleCodeExpectation = expectation(description: "Should start parallel code")
		startParalleCodeExpectation.expectedFulfillmentCount = source.count
		let finishParalleCodeExpectation = expectation(description: "Should finish parallel code")
		finishParalleCodeExpectation.expectedFulfillmentCount = source.count
		var parallelCodeFinished = false
		let parallelCodeFinishedLock = NSLock()
		
		HoneyBee.start()
                .insert(source)
				.each() { elem in
					elem.limit(1) { link in
						link.chain(asynchronouslyHoldLock)
							.chain(asynchronouslyHoldLock)
							.chain(asynchronouslyHoldLock)
						}
						.drop
						.chain(startParalleCodeExpectation.fulfill)
						// parallelize
						.chain{ _ in usleep(sleepNanoSeconds * 3) }
						.drop
						.chain(finishParalleCodeExpectation.fulfill)
						.chain({ () -> Void in
							parallelCodeFinishedLock.lock()
							parallelCodeFinished = true
							parallelCodeFinishedLock.unlock()
						})
				}
				.drop
				.chain{ XCTAssert(parallelCodeFinished, "the parallel code should have finished before this") }
				.chain(finishExpectation.fulfill)
                .error(fail)
		
		let sleepSeconds = (Double(sleepNanoSeconds)/1000.0)
		waitForExpectations(timeout: TimeInterval(Double(source.count) * sleepSeconds * 4.0 + 2.0)) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testLimitReturnChain() {
		let intermediateExpectation = expectation(description: "Should reach the intermediate end")
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		
		var intermediateFullfilled = false
		
		HoneyBee.start()
                .limit(29) { link in
					link.insert("Right")
						.chain(self.funcContainer.stringCat).drop
						.chain(intermediateExpectation.fulfill)
						.chain{ intermediateFullfilled = true }
				}
				.chain{ XCTAssert(intermediateFullfilled, "Intermediate expectation not fullfilled") }
				.chain(finishExpectation.fulfill)
                .error(fail)
		
		waitForExpectations(timeout: 3) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testLimitNoReturn() {
		let source = Array(0..<20)
		let expect = expectation(description: "Should reach the expectation")
		expect.expectedFulfillmentCount = source.count
		
		let methodIsAccesssing: AtomicBool = false
		
		func fullfilExpectationAtomically() {
			if methodIsAccesssing.get() {
				XCTFail("Overlapping invocation")
			}
			methodIsAccesssing.setTrue()
			expect.fulfill()
			methodIsAccesssing.setFalse()
		}
		
		HoneyBee.start()
				.insert(source)
				.each { elem in
					elem.limit(1) { link in
						link.drop
							.chain(expect.fulfill)
						
						let _ = link.drop // not semantically relevant.
						// Just need this to invoke the "no return" form limit.
					}
				}
                .error(fail)
		
		waitForExpectations(timeout: 3) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testParallelReduce() {
	
		let source = Array(0...10)
		let result = 55
		
		let finishExpectation = expectation(description: "Should reach the end of the chain")
		
		HoneyBee.start()
				.insert(source)
				.reduce { pair in
					pair.chain(+)
				}
				.chain{ XCTAssert($0 == result, "Reduce failed. Expected: \(result). Received: \($0).") }
				.chain(finishExpectation.fulfill)
		
		
		waitForExpectations(timeout: 3) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
	
	func testMismatchedJoin() {
		let expectA = expectation(description: "Join should casuse a failure")
		
		HoneyBee.mismatchedConjoinResponse = .custom(handler: { (message) in
			expectA.fulfill()
		})
		
		HoneyBee.start()
				.branch { stem in
					stem.drop
						.move(to: DispatchQueue.main)
						.chain(self.funcContainer.constantInt)
					+
					stem.drop
					  	.move(to: DispatchQueue.global())
						.chain(self.funcContainer.constantString)
				}
                .error(fail)
		
		waitForExpectations(timeout: 3) { error in
			if let error = error {
				XCTFail("waitForExpectationsWithTimeout errored: \(error)")
			}
		}
	}
}
