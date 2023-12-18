// The Swift Programming Language
// https://docs.swift.org/swift-book

import CustomDump
import XCTest

public struct Wrapper<T> {
    private(set) var value: T
    
    init(_ value: T) {
        self.value = value
    }
    
    public mutating func change<D: Equatable>(_ path: WritableKeyPath<T, D>,
                                       _ newValue: D,
                                       file: StaticString = #filePath,
                                       line: UInt = #line) {
        XCTAssertNotEqual(newValue, self.value[keyPath: path], file: file, line: line)
        self.value[keyPath: path] = newValue
    }
}

public func verify<State: Equatable>(given: ()->State,
                              when: ()->(),
                              then: (inout Wrapper<State>)->(),
                              file: StaticString = #filePath,
                              line: UInt = #line) {
    var wrappedState = Wrapper<State>(given())
    then(&wrappedState)
    when()
    let newState = given()
    XCTAssertEqual(wrappedState.value, newState, file: file, line: line)
}

public func verify<State: Equatable>(given: ()->State,
                              when: ()throws->(),
                              then: (inout Wrapper<State>)->(),
                              file: StaticString = #filePath,
                              line: UInt = #line) throws {
    var wrappedState = Wrapper<State>(given())
    then(&wrappedState)
    try when()
    let newState = given()
    XCTAssertEqual(wrappedState.value, newState, file: file, line: line)
}
