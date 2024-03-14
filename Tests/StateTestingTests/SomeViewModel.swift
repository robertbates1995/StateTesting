//
//  SUT.swift
//  
//
//  Created by Robert Bates on 3/13/24.
//

import Foundation

@Observable
class SomeViewModel {
    var testString: String = ""
    var testInt: Int = 0
    var testOptional: Bool?
    var networkRequestRunning = false
    var networkCall: ()async->String = {""}
    
    func changeOneThing() {
        testInt = testInt + 1
    }
    
    func changeMultiple() {
        testInt = testInt + 1
        testString += "test string"
    }
    
    func resetPressed() {
        testString = ""
        testInt = 0
        testOptional = nil
    }
    
    func networkRequestPressed() {
        networkRequestRunning = true
        //simulates user starting network request
    }
    
    func networkRequestRecieved(value: String) {
        //simulates network request is finished
        networkRequestRunning = false
        testString = value
    }
    
    func asyncNetworkRequestPressed() async {
        networkRequestRunning = true
        testString = await networkCall()
        //simulates user starting network request
        networkRequestRunning = false
    }

}
