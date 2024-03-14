import XCTest
@testable import StateTesting

struct TestState: Equatable {
    var testString: String
    var testInt: Int
    var testOptional: Bool?
    var networkRequestRunning: Bool
    
    init(_ model: SomeViewModel) {
        self.testInt = model.testInt
        self.testString = model.testString
        self.testOptional = model.testOptional
        self.networkRequestRunning = model.networkRequestRunning
    }
}

final class StateTestingTests: XCTestCase {
    let sut = SomeViewModel()
    lazy var given = StateTester(given: {[unowned self] in TestState(self.sut)})
    
    func testChangeOne() {
        given.when( {sut.changeOneThing()}) {
            $0.change(\.testInt, 1)
        }
    }
    
    func testAsync1() async {
        sut.networkCall = {
            return "test value"
        }
        
        await given.when({
            await sut.asyncNetworkRequestPressed()
        }) {
            $0.change(\.testString, "test value")
        }
    }
    
    func testAsync2() async {
        let exp1 = expectation(description: "exp 1")
        let exp2 = expectation(description: "exp 2")
        let exp3 = expectation(description: "exp 3")
        
        sut.networkCall = { [unowned self] in
            exp1.fulfill()
            await fulfillment(of: [exp2])
            return "test value"
        }
        
        await given.when({
            Task {
                await sut.asyncNetworkRequestPressed()
                exp3.fulfill()
            }
            await fulfillment(of: [exp1])
        }) {
            $0.change(\.networkRequestRunning, true)
        }
        
        await given.when({
            exp2.fulfill()
            await fulfillment(of: [exp3])
        }) {
            $0.change(\.networkRequestRunning, false)
            $0.change(\.testString, "test value")
        }
    }
    
    func testChangeMultiple() {
        given.when({sut.changeMultiple()}) {
            $0.change(\.testInt, 1)
            $0.change(\.testString, "test string")
        }
    }
    
    func testNoChange() {
// uncomment to see what happens when the original value is not different than the final value
//        given.when({sut.changeOneThing()}) {
//            $0.change(\.testInt, 0)
//        }
    }

    func testReset() {
        sut.testInt = 1
        sut.testString = "foo"
        sut.testOptional = false
        given.when({sut.resetPressed()}) {
            $0.change(\.testInt, 0)
            $0.change(\.testString, "")
            $0.change(\.testOptional, nil)
        }
        given.when({sut.resetPressed()}) { _ in }
    }
    
    func testNetworkRequest() {
        given.when({sut.networkRequestPressed()}) {
            $0.change(\.networkRequestRunning, true)
        }
        given.when({sut.networkRequestRecieved(value: "test value")}) {
            $0.change(\.networkRequestRunning, false)
            $0.change(\.testString, "test value")
        }
    }
}
