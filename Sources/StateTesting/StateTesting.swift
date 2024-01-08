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

public struct StateTester<State: Equatable> {
    let stateCapture: ()->State
    
    public init(given: @escaping ()->State) {
        stateCapture = given
    }
    
    public func when(_ change: ()->(), _ then: (inout Wrapper<State>)->(), file: StaticString = #filePath, line: UInt = #line)->() {
        var wrappedState = Wrapper<State>(stateCapture())
        then(&wrappedState)
        change()
        let newState = stateCapture()
        XCTAssertEqual(wrappedState.value, newState, file: file, line: line)
    }
    
    public func when(_ change: ()throws->(), _ then: (inout Wrapper<State>)->(), file: StaticString = #filePath, line: UInt = #line)rethrows->() {
        var wrappedState = Wrapper<State>(stateCapture())
        then(&wrappedState)
        try change()
        let newState = stateCapture()
        XCTAssertEqual(wrappedState.value, newState, file: file, line: line)
    }
}
