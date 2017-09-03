import UIKit
import XCTest

// MARK: The Good
protocol Villain {
	func move()
}

struct Ghost: Villain {
	var opacity: CGFloat
	var color: UIColor
	
	func move() {
		print("Moving Ghost")
	}
}

struct Vampire: Villain {
	var canTurnIntoBat: Bool
	var canHandleSunlight: Bool
	
	func move() {
		print("Moving Vampire")
	}
}


let villains: [Villain] = [
	Ghost(opacity: 0.5, color: .red),
	Vampire(canTurnIntoBat: true, canHandleSunlight: false)
]

for villain in villains {
	villain.move()
}

// Will generate a compile time error
// (5 as Villain).move()

// MARK: - The Nice
typealias PList = [String: Any]

protocol Storage {
	func store(data: PList)
	func retrieveData() -> PList?
}

extension UserDefaults: Storage {
	var appKey: String {
		return "Test-App-Key"
	}
	
	func store(data: PList) {
		UserDefaults.standard.set(data, forKey: appKey)
	}
	
	func retrieveData() -> PList? {
		guard let storedData = UserDefaults.standard.value(forKey: appKey) as? PList else {
			return nil
		}
		
		return storedData
	}
}

func save(data: PList, in storage: Storage) {
	storage.store(data: data)
}

let data: [String: Any] = ["val1" : true, "val2": [1, 2, 3], "val3": 0.5]
save(data: data, in: UserDefaults.standard)

class SaveTest: XCTestCase {
	struct StorageMock: Storage {
		var onStore: (() -> Void)?
		var onRetrieve: (() -> Void)?
		
		func store(data: PList) {
			onStore?()
		}
		
		func retrieveData() -> PList? {
			onRetrieve?()
			return nil
		}
	}
	
	func testSave() {
		let didStoreExpectation = expectation(description: "Should invoke storage store function")
		let storage = StorageMock(onStore: {
			didStoreExpectation.fulfill()
		}, onRetrieve: nil)
		
		save(data: ["val1": "Testing"], in: storage)
		waitForExpectations(timeout: 0.1, handler: nil)
	}
}

SaveTest.defaultTestSuite.run()

// MARK: The Weird
protocol Moveable {
	var point: CGPoint { get set }
	mutating func move(byOffset offset: CGPoint)
}

extension Moveable {
	mutating func move(byOffset offset: CGPoint) {
		print("default move invoked")
		point.x += offset.x
		point.y += offset.y
	}
}

class GameObject: Moveable {
	var point: CGPoint
	
	init(point: CGPoint) {
		self.point = point
	}
}

class Bird: GameObject {
	func move(byOffset offset: CGPoint) {
		print("Flapping wings")
	}
}

// Uncomment and comment out the previous Bird definition
// to fix weird behavior
//struct Bird: Moveable {
//	var point: CGPoint
//
//	func move(byOffset offset: CGPoint) {
//		print("Flapping wings")
//	}
//}

func teleport(moveable: Moveable, to location: CGPoint) {
	let offset = CGPoint(x: location.x - moveable.point.x, y: location.y - moveable.point.y)
	var mutableMoveable = moveable // allow mutation
	mutableMoveable.move(byOffset: offset)
}

var bird: Bird = Bird(point: CGPoint.zero)
teleport(moveable: bird, to: CGPoint(x: 2.0, y: 3.0))
