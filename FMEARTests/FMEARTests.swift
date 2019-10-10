//
//  FMEARTests.swift
//  FMEARTests
//
//  Created by Angus Lau on 2019-10-09.
//  Copyright © 2019 Safe Software Inc. All rights reserved.
//

import XCTest

@testable import FME_AR

class FMEARUnitTestsForSettings: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEmptySettings() {
        let settings = Settings()
        XCTAssertNil(settings.version, "version should be nil by default")
        XCTAssertNil(settings.scaling, "scaling should be nil by default")
        XCTAssertNil(settings.anchorFeatureType, "anchorFeatureType should be nil by default")
        XCTAssertNotNil(settings.anchors, "anchors should not be nil by default")
        XCTAssertEqual(settings.anchors.count, 0, "anchors should be empty by default")
    }
    
    func testVersion1() {
        do // Test: {"version":"1","scaling":"fit"}
        {
            let testString = "{\"version\":\"1\",\"scaling\":\"fit\"}"
            do {
                let data = testString.data(using: .utf8)
                XCTAssertNotNil(data, "Invalid test data: \(testString)")
                
                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: [])
                let settings = try Settings(json: jsonDict)
                
                XCTAssertEqual(settings.version, "1", "version should be 1")
                XCTAssertNil(settings.scaling, "scaling should be nil when \"scaling\":\"fit\" is set")
                XCTAssertNil(settings.anchorFeatureType, "anchorFeatureType should be nil in version 1")
                XCTAssertNotNil(settings.anchors, "anchors should not be nil by default")
                XCTAssertEqual(settings.anchors.count, 0, "anchors should be empty by default")
            } catch {
                XCTFail("Settings init throws an exception with data '\(testString)'")
            }
        }

        do // Test: {"version":"1","scaling":"1to1"}
        {
            let testString = "{\"version\":\"1\",\"scaling\":\"1to1\"}"
            do {
                let data = testString.data(using: .utf8)
                XCTAssertNotNil(data, "Invalid test data: \(testString)")
                
                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: [])
                let settings = try Settings(json: jsonDict)
                
                XCTAssertEqual(settings.version, "1", "version should be 1")
                XCTAssertEqual(settings.scaling, 1, "scaling should be 1 when \"scaling\":\"1to1\" is set")
                XCTAssertNil(settings.anchorFeatureType, "anchorFeatureType should be nil in version 1")
                XCTAssertNotNil(settings.anchors, "anchors should not be nil by default")
                XCTAssertEqual(settings.anchors.count, 0, "anchors should be empty by default")
            } catch {
                XCTFail("Settings init throws an exception with data '\(testString)'")
            }
        }
    }
    
    func testVersion2() {
        do // Test: {"version":"2","scaling":"fit"}
        {
            let testString = "{\"version\":\"2\",\"scaling\":\"fit\"}"
            do {
                let data = testString.data(using: .utf8)
                XCTAssertNotNil(data, "Invalid test data: \(testString)")
                
                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: [])
                let settings = try Settings(json: jsonDict)
                
                XCTAssertEqual(settings.version, "2", "version should be 2")
                XCTAssertNil(settings.scaling, "scaling should be nil when \"scaling\":\"fit\" is set")
                XCTAssertNil(settings.anchorFeatureType, "anchorFeatureType should be nil")
                XCTAssertNotNil(settings.anchors, "anchors should not be nil by default")
                XCTAssertEqual(settings.anchors.count, 0, "anchors should be empty by default")
            } catch {
                XCTFail("Settings init throws an exception with data '\(testString)'")
            }
        }

        do // Test: {"version":"2","scaling":"fit","zoom":"no"}
        {
            let testString = "{\"version\":\"2\",\"scaling\":\"fit\",\"zoom\":\"no\"}"
            do {
                let data = testString.data(using: .utf8)
                XCTAssertNotNil(data, "Invalid test data: \(testString)")
                
                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: [])
                let settings = try Settings(json: jsonDict)
                
                XCTAssertEqual(settings.version, "2", "version should be 2")
                XCTAssertNil(settings.scaling, "scaling should be nil when \"scaling\":\"fit\" is set")
                XCTAssertNil(settings.anchorFeatureType, "anchorFeatureType should be nil")
                XCTAssertNotNil(settings.anchors, "anchors should not be nil by default")
                XCTAssertEqual(settings.anchors.count, 0, "anchors should be empty by default")
            } catch {
                XCTFail("Settings init throws an exception with data '\(testString)'")
            }
        }

        do // Test: {"version":"2","scaling":"1to1","zoom":"yes"}
        {
            let testString = "{\"version\":\"2\",\"scaling\":\"1to1\",\"zoom\":\"yes\"}"
            do {
                let data = testString.data(using: .utf8)
                XCTAssertNotNil(data, "Invalid test data: \(testString)")
                
                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: [])
                let settings = try Settings(json: jsonDict)
                
                XCTAssertEqual(settings.version, "2", "version should be 2")
                XCTAssertEqual(settings.scaling, 1, "scaling should be 1 when \"scaling\":\"1to1\" is set")
                XCTAssertNil(settings.anchorFeatureType, "anchorFeatureType should be nil if anchor is not set")
                XCTAssertNotNil(settings.anchors, "anchors should not be nil by default")
                XCTAssertEqual(settings.anchors.count, 0, "anchors should be empty by default")
            } catch {
                XCTFail("Settings init throws an exception with data '\(testString)'")
            }
        }

        do // Test: {"version":"2","scaling":"1to1","zoom":"yes","anchor":"Beam"}
        {
            let testString = "{\"version\":\"2\",\"scaling\":\"1to1\",\"zoom\":\"yes\",\"anchor\":\"Beam\"}"
            do {
                let data = testString.data(using: .utf8)
                XCTAssertNotNil(data, "Invalid test data: \(testString)")
                
                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: [])
                let settings = try Settings(json: jsonDict)
                
                XCTAssertEqual(settings.version, "2", "version should be 2")
                XCTAssertEqual(settings.scaling, 1, "scaling should be 1 when \"scaling\":\"1to1\" is set")
                XCTAssertEqual(settings.anchorFeatureType, "Beam", "anchorFeatureType should be set to \"Beam\"")
                XCTAssertNotNil(settings.anchors, "anchors should not be nil by default")
                XCTAssertEqual(settings.anchors.count, 0, "anchors should be empty by default")
            } catch {
                XCTFail("Settings init throws an exception with data '\(testString)'")
            }
        }
    }
    
    func testVersion3() {
        do // Test: {"version":"3","anchor":{"x":"5.23","y":"-2.56"}}
        {
            let testString = "{\"version\":\"3\",\"anchor\":{\"x\":\"5.23\",\"y\":\"-2.56\"}}"
            do {
                let data = testString.data(using: .utf8)
                XCTAssertNotNil(data, "Invalid test data: \(testString)")
                
                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: [])
                let settings = try Settings(json: jsonDict)
                
                XCTAssertEqual(settings.version, "3", "version should be 3")
                XCTAssertNil(settings.scaling, "scaling should be nil")
                XCTAssertNil(settings.anchorFeatureType, "anchorFeatureType should be nil")
                XCTAssertNotNil(settings.anchors, "anchors should not be nil by default")
                XCTAssertEqual(settings.anchors.count, 1, "anchors should have 1 entry")
                if let anchor = settings.anchors.first {
                    XCTAssertEqual(anchor.x, 5.23)
                    XCTAssertEqual(anchor.y, -2.56)
                    XCTAssertNil(anchor.z, "z should be nil when it's not set")
                    XCTAssertNil(anchor.coordinate, "coordinate should be nil when it's not set")
                }
            } catch {
                XCTFail("Settings init throws an exception with data '\(testString)'")
            }
        }
        
        do // Test: {"version":"3","scaling":"1to1","anchor":{"x":"5.23","y":"-2.56","z":"10"}}
        {
            let testString = "{\"version\":\"3\",\"scaling\":\"1to1\",\"anchor\":{\"x\":\"5.23\",\"y\":\"-2.56\",\"z\":\"10\"}}"
            do {
                let data = testString.data(using: .utf8)
                XCTAssertNotNil(data, "Invalid test data: \(testString)")
                
                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: [])
                let settings = try Settings(json: jsonDict)
                
                XCTAssertEqual(settings.version, "3", "version should be 3")
                XCTAssertEqual(settings.scaling, 1, "scaling should be 1 when \"scaling\":\"1to1\" is set")
                XCTAssertNil(settings.anchorFeatureType, "anchorFeatureType should be nil")
                XCTAssertNotNil(settings.anchors, "anchors should not be nil by default")
                XCTAssertEqual(settings.anchors.count, 1, "anchors should have 1 entry")
                if let anchor = settings.anchors.first {
                    XCTAssertEqual(anchor.x, 5.23)
                    XCTAssertEqual(anchor.y, -2.56)
                    XCTAssertEqual(anchor.z, 10)
                    XCTAssertNil(anchor.coordinate, "coordinate should be nil when it's not set")
                }
            } catch {
                XCTFail("Settings init throws an exception with data '\(testString)'")
            }
        }

        do // Test: {"version":"3","anchor":{"x":"5.23","y":"-2.56","latitude":"45.678901","longitude":"123.456789"}}
        {
            let testString = "{\"version\":\"3\",\"anchor\":{\"x\":\"5.23\",\"y\":\"-2.56\",\"latitude\":\"45.678901\",\"longitude\":\"123.456789\"}}"
            do {
                let data = testString.data(using: .utf8)
                XCTAssertNotNil(data, "Invalid test data: \(testString)")
                
                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: [])
                let settings = try Settings(json: jsonDict)
                
                XCTAssertEqual(settings.version, "3", "version should be 3")
                XCTAssertNil(settings.scaling, "scaling should be nil")
                XCTAssertNil(settings.anchorFeatureType, "anchorFeatureType should be nil")
                XCTAssertNotNil(settings.anchors, "anchors should not be nil by default")
                XCTAssertEqual(settings.anchors.count, 1, "anchors should have 1 entry")
                if let anchor = settings.anchors.first {
                    XCTAssertEqual(anchor.x, 5.23)
                    XCTAssertEqual(anchor.y, -2.56)
                    XCTAssertNil(anchor.z, "z should be nil when it's not set")
                    XCTAssertEqual(anchor.coordinate?.latitude, 45.678901)
                    XCTAssertEqual(anchor.coordinate?.longitude, 123.456789)
                }
            } catch {
                XCTFail("Settings init throws an exception with data '\(testString)'")
            }
        }

        do // Test: {"version":"3","anchor":{"latitude":"45.678901","longitude":"123.456789"}}
        {
            let testString = "{\"version\":\"3\",\"anchor\":{\"latitude\":\"45.678901\",\"longitude\":\"123.456789\"}}"
            do {
                let data = testString.data(using: .utf8)
                XCTAssertNotNil(data, "Invalid test data: \(testString)")
                
                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: [])
                let settings = try Settings(json: jsonDict)
                
                XCTAssertEqual(settings.version, "3", "version should be 3")
                XCTAssertNil(settings.scaling, "scaling should be nil")
                XCTAssertNil(settings.anchorFeatureType, "anchorFeatureType should be nil")
                XCTAssertNotNil(settings.anchors, "anchors should not be nil by default")
                XCTAssertEqual(settings.anchors.count, 1, "anchors should have 1 entry")
                if let anchor = settings.anchors.first {
                    XCTAssertNil(anchor.x, "x should be nil when it's not set")
                    XCTAssertNil(anchor.y, "y should be nil when it's not set")
                    XCTAssertNil(anchor.z, "z should be nil when it's not set")
                    XCTAssertEqual(anchor.coordinate?.latitude, 45.678901)
                    XCTAssertEqual(anchor.coordinate?.longitude, 123.456789)
                }
            } catch {
                XCTFail("Settings init throws an exception with data '\(testString)'")
            }
        }
        
        do // Test: {"version":"3","scaling":"1to1","anchor":[{"x":"1.1","y":"-2.2","latitude":"3.3","longitude":"-4.4"},{"x":"5.5","y":"-6.6","latitude":"7.7","longitude":"-8.8"}]}
        {
            let testString = "{\"version\":\"3\",\"scaling\":\"1to1\",\"anchor\":[{\"x\":\"1.1\",\"y\":\"-2.2\",\"latitude\":\"3.3\",\"longitude\":\"-4.4\"},{\"x\":\"5.5\",\"y\":\"-6.6\",\"latitude\":\"7.7\",\"longitude\":\"-8.8\"}]}"
            do {
                let data = testString.data(using: .utf8)
                XCTAssertNotNil(data, "Invalid test data: \(testString)")
                
                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: [])
                let settings = try Settings(json: jsonDict)
                
                XCTAssertEqual(settings.version, "3", "version should be 3")
                XCTAssertEqual(settings.scaling, 1, "scaling should be 1")
                XCTAssertNil(settings.anchorFeatureType, "anchorFeatureType should be nil")
                XCTAssertNotNil(settings.anchors, "anchors should not be nil by default")
                XCTAssertEqual(settings.anchors.count, 2, "anchors should have 2 entries")
                if let anchor = settings.anchors.first {
                    XCTAssertEqual(anchor.x, 1.1)
                    XCTAssertEqual(anchor.y, -2.2)
                    XCTAssertNil(anchor.z, "z should be nil when it's not set")
                    XCTAssertEqual(anchor.coordinate?.latitude, 3.3)
                    XCTAssertEqual(anchor.coordinate?.longitude, -4.4)
                }
                if let anchor = settings.anchors.last {
                    XCTAssertEqual(anchor.x, 5.5)
                    XCTAssertEqual(anchor.y, -6.6)
                    XCTAssertNil(anchor.z, "z should be nil when it's not set")
                    XCTAssertEqual(anchor.coordinate?.latitude, 7.7)
                    XCTAssertEqual(anchor.coordinate?.longitude, -8.8)
                }
            } catch {
                XCTFail("Settings init throws an exception with data '\(testString)'")
            }
        }
    }
}
