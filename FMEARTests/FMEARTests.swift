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

        do // Test: {"version":"3","anchor":{"x":5.23,"y":-2.56}}
        {
            let testString = "{\"version\":\"3\",\"anchor\":{\"x\":5.23,\"y\":-2.56}}"
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
        
        do // Test: {"version":"3","anchor":{"x":5.23,"y":-2.56,"latitude":45.678901,"longitude":123.456789}}
        {
            let testString = "{\"version\":\"3\",\"anchor\":{\"x\":5.23,\"y\":-2.56,\"latitude\":45.678901,\"longitude\":123.456789}}"
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
        
        do // Test: {"version":"3","scaling":"1to100"}
        {
            let testString = "{\"version\":\"3\",\"scaling\":\"1to100\"}"
            do {
                let data = testString.data(using: .utf8)
                XCTAssertNotNil(data, "Invalid test data: \(testString)")

                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: [])
                let settings = try Settings(json: jsonDict)
                
                XCTAssertEqual(settings.version, "3", "version should be 3")
                XCTAssertEqual(settings.scaling, 0.01, "scaling should be 0.01")
            } catch {
                XCTFail("Settings init throws an exception with data '\(testString)'")
            }
        }

        do // Test: {"version":"3","scaling":"1:100"}
        {
            let testString = "{\"version\":\"3\",\"scaling\":\"1:100\"}"
            do {
                let data = testString.data(using: .utf8)
                XCTAssertNotNil(data, "Invalid test data: \(testString)")

                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: [])
                let settings = try Settings(json: jsonDict)
                
                XCTAssertEqual(settings.version, "3", "version should be 3")
                XCTAssertEqual(settings.scaling, 0.01, "scaling should be 0.01")
            } catch {
                XCTFail("Settings init throws an exception with data '\(testString)'")
            }
        }

        do // Test: {"version":"3","scaling":"100to2.5"}
        {
            let testString = "{\"version\":\"3\",\"scaling\":\"100to2.5\"}"
            do {
                let data = testString.data(using: .utf8)
                XCTAssertNotNil(data, "Invalid test data: \(testString)")

                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: [])
                let settings = try Settings(json: jsonDict)
                
                XCTAssertEqual(settings.version, "3", "version should be 3")
                XCTAssertEqual(settings.scaling, 40, "scaling should be 40")
            } catch {
                XCTFail("Settings init throws an exception with data '\(testString)'")
            }
        }

        do // Test: {"version":"3","scaling":"100:2.5"}
        {
            let testString = "{\"version\":\"3\",\"scaling\":\"100:2.5\"}"
            do {
                let data = testString.data(using: .utf8)
                XCTAssertNotNil(data, "Invalid test data: \(testString)")

                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: [])
                let settings = try Settings(json: jsonDict)
                
                XCTAssertEqual(settings.version, "3", "version should be 3")
                XCTAssertEqual(settings.scaling, 40, "scaling should be 40")
            } catch {
                XCTFail("Settings init throws an exception with data '\(testString)'")
            }
        }

        do // Test: {"version":"3","scaling":"40"}
        {
            let testString = "{\"version\":\"3\",\"scaling\":\"40\"}"
            do {
                let data = testString.data(using: .utf8)
                XCTAssertNotNil(data, "Invalid test data: \(testString)")

                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: [])
                let settings = try Settings(json: jsonDict)
                
                XCTAssertEqual(settings.version, "3", "version should be 3")
                XCTAssertEqual(settings.scaling, 40, "scaling should be 40")
            } catch {
                XCTFail("Settings init throws an exception with data '\(testString)'")
            }
        }

        do // Test: {"version":"3","scaling":40}
        {
            let testString = "{\"version\":\"3\",\"scaling\":40}"
            do {
                let data = testString.data(using: .utf8)
                XCTAssertNotNil(data, "Invalid test data: \(testString)")

                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: [])
                let settings = try Settings(json: jsonDict)
                
                XCTAssertEqual(settings.version, "3", "version should be 3")
                XCTAssertEqual(settings.scaling, 40, "scaling should be 40")
            } catch {
                XCTFail("Settings init throws an exception with data '\(testString)'")
            }
        }
        
        do // Test: {"version":"3","scaling":"0.04"}
        {
            let testString = "{\"version\":\"3\",\"scaling\":\"0.04\"}"
            do {
                let data = testString.data(using: .utf8)
                XCTAssertNotNil(data, "Invalid test data: \(testString)")

                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: [])
                let settings = try Settings(json: jsonDict)
                
                XCTAssertEqual(settings.version, "3", "version should be 3")
                XCTAssertEqual(settings.scaling, 0.04, "scaling should be 0.04")
            } catch {
                XCTFail("Settings init throws an exception with data '\(testString)'")
            }
        }
        
        do // Test: {"version":"3","scaling":0.04}
        {
            let testString = "{\"version\":\"3\",\"scaling\":0.04}"
            do {
                let data = testString.data(using: .utf8)
                XCTAssertNotNil(data, "Invalid test data: \(testString)")

                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: [])
                let settings = try Settings(json: jsonDict)
                
                XCTAssertEqual(settings.version, "3", "version should be 3")
                XCTAssertEqual(settings.scaling, 0.04, "scaling should be 0.04")
            } catch {
                XCTFail("Settings init throws an exception with data '\(testString)'")
            }
        }
    }
    
    func testVersion4() {
        
        // Test: Initial Model Scaling = <Empty>
        // {"version":"4","viewpoints":[]}
        do
        {
            let testString = "{\"version\":\"4\",\"viewpoints\":[]}"
            do {
                let data = testString.data(using: .utf8)
                XCTAssertNotNil(data, "Invalid test data: \(testString)")
                
                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: [])
                let settings = try Settings(json: jsonDict)
                
                XCTAssertEqual(settings.version, "4", "version should be 4")
                XCTAssertNil(settings.scaling, "scaling should be nil")
                XCTAssertNil(settings.anchorFeatureType, "anchorFeatureType should be nil")
                XCTAssertNotNil(settings.anchors, "anchors should not be nil by default")
                XCTAssertEqual(settings.anchors.count, 0, "anchors should have 0 entry")
                XCTAssertNotNil(settings.viewpoints, "viewpoints should not be nil by default")
                XCTAssertEqual(settings.viewpoints.count, 0, "viewpoints should have 0 entry")
            } catch {
                XCTFail("Settings init throws an exception with data '\(testString)'")
            }
        }
        
        // Test: Initial Model Scaling = Fit
        // {"version":"4","scaling":"fit","viewpoints":[]}
        do
        {
            let testString = "{\"version\":\"4\",\"scaling\":\"fit\",\"viewpoints\":[]}"
            do {
                let data = testString.data(using: .utf8)
                XCTAssertNotNil(data, "Invalid test data: \(testString)")
                
                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: [])
                let settings = try Settings(json: jsonDict)
                
                XCTAssertEqual(settings.version, "4", "version should be 4")
                XCTAssertNil(settings.scaling, "scaling should be nil when \"scaling\":\"fit\" is set")
                XCTAssertNil(settings.anchorFeatureType, "anchorFeatureType should be nil")
                XCTAssertNotNil(settings.anchors, "anchors should not be nil by default")
                XCTAssertEqual(settings.anchors.count, 0, "anchors should have 0 entry")
                XCTAssertNotNil(settings.viewpoints, "viewpoints should not be nil by default")
                XCTAssertEqual(settings.viewpoints.count, 0, "viewpoints should have 0 entry")
            } catch {
                XCTFail("Settings init throws an exception with data '\(testString)'")
            }
        }
        
        // Test: Initial Model Scaling = Full Scale
        // {"version":"4","scaling":"1to1","viewpoints":[]}
        do
        {
            let testString = "{\"version\":\"4\",\"scaling\":\"1to1\",\"viewpoints\":[]}"
            do {
                let data = testString.data(using: .utf8)
                XCTAssertNotNil(data, "Invalid test data: \(testString)")
                
                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: [])
                let settings = try Settings(json: jsonDict)
                
                XCTAssertEqual(settings.version, "4", "version should be 4")
                XCTAssertEqual(settings.scaling, 1, "scaling should be 1 when \"scaling\":\"1to1\" is set")
                XCTAssertNil(settings.anchorFeatureType, "anchorFeatureType should be nil")
                XCTAssertNotNil(settings.anchors, "anchors should not be nil by default")
                XCTAssertEqual(settings.anchors.count, 0, "anchors should have 0 entry")
                XCTAssertNotNil(settings.viewpoints, "viewpoints should not be nil by default")
                XCTAssertEqual(settings.viewpoints.count, 0, "viewpoints should have 0 entry")
            } catch {
                XCTFail("Settings init throws an exception with data '\(testString)'")
            }
        }
        
        // Test: Initial Model Scaling = Custom = 1
        // {"version":"4","scaling":"1","viewpoints":[]}
        do
        {
            let testString = "{\"version\":\"4\",\"scaling\":\"1\",\"viewpoints\":[]}"
            do {
                let data = testString.data(using: .utf8)
                XCTAssertNotNil(data, "Invalid test data: \(testString)")
                
                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: [])
                let settings = try Settings(json: jsonDict)
                
                XCTAssertEqual(settings.version, "4", "version should be 4")
                XCTAssertEqual(settings.scaling, 1, "scaling should be 1 when \"scaling\":\"1\" is set")
                XCTAssertNil(settings.anchorFeatureType, "anchorFeatureType should be nil")
                XCTAssertNotNil(settings.anchors, "anchors should not be nil by default")
                XCTAssertEqual(settings.anchors.count, 0, "anchors should have 0 entry")
                XCTAssertNotNil(settings.viewpoints, "viewpoints should not be nil by default")
                XCTAssertEqual(settings.viewpoints.count, 0, "viewpoints should have 0 entry")
            } catch {
                XCTFail("Settings init throws an exception with data '\(testString)'")
            }
        }
        
        // Test: Initial Model Scaling = Custom = 0.2
        // {"version":"4","scaling":"0.2","viewpoints":[]}
        do
        {
            let testString = "{\"version\":\"4\",\"scaling\":\"0.2\",\"viewpoints\":[]}"
            do {
                let data = testString.data(using: .utf8)
                XCTAssertNotNil(data, "Invalid test data: \(testString)")
                
                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: [])
                let settings = try Settings(json: jsonDict)
                
                XCTAssertEqual(settings.version, "4", "version should be 4")
                XCTAssertEqual(settings.scaling, 0.2, "scaling should be 0.2 when \"scaling\":\"0.2\" is set")
                XCTAssertNil(settings.anchorFeatureType, "anchorFeatureType should be nil")
                XCTAssertNotNil(settings.anchors, "anchors should not be nil by default")
                XCTAssertEqual(settings.anchors.count, 0, "anchors should have 0 entry")
                XCTAssertNotNil(settings.viewpoints, "viewpoints should not be nil by default")
                XCTAssertEqual(settings.viewpoints.count, 0, "viewpoints should have 0 entry")
            } catch {
                XCTFail("Settings init throws an exception with data '\(testString)'")
            }
        }
        
        // Test: Initial Model Scaling = Fit, One viewpoint
        // {"version":"4","scaling":"fit","viewpoints":[{"x":-99.69291200000043,"y":851.8795360000004}]}
        do
        {
            let testString = "{\"version\":\"4\",\"scaling\":\"fit\",\"viewpoints\":[{\"x\":-99.69291200000043,\"y\":851.8795360000004}]}"
            do {
                let data = testString.data(using: .utf8)
                XCTAssertNotNil(data, "Invalid test data: \(testString)")
                
                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: [])
                let settings = try Settings(json: jsonDict)
                
                XCTAssertEqual(settings.version, "4", "version should be 4")
                XCTAssertNil(settings.scaling, "scaling should be nil when \"scaling\":\"fit\" is set")
                XCTAssertNil(settings.anchorFeatureType, "anchorFeatureType should be nil")
                XCTAssertNotNil(settings.anchors, "anchors should not be nil by default")
                XCTAssertEqual(settings.anchors.count, 0, "anchors should have 0 entry")
                XCTAssertNotNil(settings.viewpoints, "viewpoints should not be nil by default")
                XCTAssertEqual(settings.viewpoints.count, 1, "viewpoints should have 1 entry")
                if let viewpoint = settings.viewpoints.first {
                    XCTAssertEqual(viewpoint.x, -99.69291200000043)
                    XCTAssertEqual(viewpoint.y, 851.8795360000004)
                    XCTAssertNil(viewpoint.z, "z should be nil when it's not set")
                    XCTAssertNil(viewpoint.name, "name should be nil when it's not set")
                }
            } catch {
                XCTFail("Settings init throws an exception with data '\(testString)'")
            }
        }
        
        // Test: Initial Model Scaling = Fit, One viewpoint with a name
        // {"version":"4","scaling":"fit","viewpoints":[
        //     {"x":-99.69291200000043,"y":851.8795360000004,"name":"x4000y4000"}
        // ]}
        do
        {
            let testString = "{\"version\":\"4\",\"scaling\":\"fit\",\"viewpoints\":[{\"x\":-99.69291200000043,\"y\":851.8795360000004,\"name\":\"x4000y4000\"}]}"
            do {
                let data = testString.data(using: .utf8)
                XCTAssertNotNil(data, "Invalid test data: \(testString)")
                
                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: [])
                let settings = try Settings(json: jsonDict)
                
                XCTAssertEqual(settings.version, "4", "version should be 4")
                XCTAssertNil(settings.scaling, "scaling should be nil when \"scaling\":\"fit\" is set")
                XCTAssertNil(settings.anchorFeatureType, "anchorFeatureType should be nil")
                XCTAssertNotNil(settings.anchors, "anchors should not be nil by default")
                XCTAssertEqual(settings.anchors.count, 0, "anchors should have 0 entry")
                XCTAssertNotNil(settings.viewpoints, "viewpoints should not be nil by default")
                XCTAssertEqual(settings.viewpoints.count, 1, "viewpoints should have 1 entry")
                if let viewpoint = settings.viewpoints.first {
                    XCTAssertEqual(viewpoint.x, -99.69291200000043)
                    XCTAssertEqual(viewpoint.y, 851.8795360000004)
                    XCTAssertNil(viewpoint.z, "z should be nil when it's not set")
                    XCTAssertEqual(viewpoint.name, "x4000y4000")
                }
            } catch {
                XCTFail("Settings init throws an exception with data '\(testString)'")
            }
        }
        
        // Test: Initial Model Scaling = Fit, Multiple viewpoints with names
        // {"version":"4","scaling":"fit","viewpoints":[
        //     {"x":15900.307088,"y":4851.879536,"name":"x20000y-8000"},
        //     {"x":-9099.692912,"y":-23148.120464,"name":"x-5000y-20000"},
        //     {"x":-99.69291200000043,"y":851.8795360000004,"name":"x4000y4000"}
        // ]}
        do
        {
            let testString =
                "{\"version\":\"4\",\"scaling\":\"fit\",\"viewpoints\":[" +
                     "{\"x\":15900.307088,\"y\":4851.879536,\"name\":\"x20000y-8000\"}," +
                     "{\"x\":-9099.692912,\"y\":-23148.120464,\"name\":\"x-5000y-20000\"}," +
                     "{\"x\":-99.69291200000043,\"y\":851.8795360000004,\"name\":\"x4000y4000\"}" +
                "]}"
            do {
                let data = testString.data(using: .utf8)
                XCTAssertNotNil(data, "Invalid test data: \(testString)")
                
                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: [])
                let settings = try Settings(json: jsonDict)
                
                XCTAssertEqual(settings.version, "4", "version should be 4")
                XCTAssertNil(settings.scaling, "scaling should be nil when \"scaling\":\"fit\" is set")
                XCTAssertNil(settings.anchorFeatureType, "anchorFeatureType should be nil")
                XCTAssertNotNil(settings.anchors, "anchors should not be nil by default")
                XCTAssertEqual(settings.anchors.count, 0, "anchors should have 0 entry")
                XCTAssertNotNil(settings.viewpoints, "viewpoints should not be nil by default")
                XCTAssertEqual(settings.viewpoints.count, 3, "viewpoints should have 3 entries")

                XCTAssertEqual(settings.viewpoints[0].x, 15900.307088)
                XCTAssertEqual(settings.viewpoints[0].y, 4851.879536)
                XCTAssertNil(settings.viewpoints[0].z, "z should be nil when it's not set")
                XCTAssertEqual(settings.viewpoints[0].name, "x20000y-8000")

                XCTAssertEqual(settings.viewpoints[1].x, -9099.692912)
                XCTAssertEqual(settings.viewpoints[1].y, -23148.120464)
                XCTAssertNil(settings.viewpoints[1].z, "z should be nil when it's not set")
                XCTAssertEqual(settings.viewpoints[1].name, "x-5000y-20000")
                
                XCTAssertEqual(settings.viewpoints[2].x, -99.69291200000043)
                XCTAssertEqual(settings.viewpoints[2].y, 851.8795360000004)
                XCTAssertNil(settings.viewpoints[2].z, "z should be nil when it's not set")
                XCTAssertEqual(settings.viewpoints[2].name, "x4000y4000")
            } catch {
                XCTFail("Settings init throws an exception with data '\(testString)'")
            }
        }
        
        // Test: Intial Model Scaling = Fit, Multiple viewpoints with names, geolocated anchor without coordinate
        // {"version":"4","scaling":"fit","anchor":{"latitude":49.178121,"longitude":-122.842716},"viewpoints":[
        //     {"x":15900.307088,"y":4851.879536,"name":"x20000y-8000"},
        //     {"x":-9099.692912,"y":-23148.120464,"name":"x-5000y-20000"},
        //     {"x":-99.69291200000043,"y":851.8795360000004,"name":"x4000y4000"}
        // ]}
        do
        {
            let testString =
                "{\"version\":\"4\",\"scaling\":\"fit\",\"anchor\":{\"latitude\":49.178121,\"longitude\":-122.842716},\"viewpoints\":[" +
                     "{\"x\":15900.307088,\"y\":4851.879536,\"name\":\"x20000y-8000\"}," +
                     "{\"x\":-9099.692912,\"y\":-23148.120464,\"name\":\"x-5000y-20000\"}," +
                     "{\"x\":-99.69291200000043,\"y\":851.8795360000004,\"name\":\"x4000y4000\"}" +
                "]}"
            do {
                let data = testString.data(using: .utf8)
                XCTAssertNotNil(data, "Invalid test data: \(testString)")
                
                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: [])
                let settings = try Settings(json: jsonDict)
                
                XCTAssertEqual(settings.version, "4", "version should be 4")
                XCTAssertNil(settings.scaling, "scaling should be nil when \"scaling\":\"fit\" is set")
                XCTAssertNil(settings.anchorFeatureType, "anchorFeatureType should be nil")
                XCTAssertNotNil(settings.anchors, "anchors should not be nil by default")
                XCTAssertEqual(settings.anchors.count, 1, "anchors should have 0 entry")
                XCTAssertNotNil(settings.viewpoints, "viewpoints should not be nil by default")
                XCTAssertEqual(settings.viewpoints.count, 3, "viewpoints should have 3 entries")

                XCTAssertEqual(settings.viewpoints[0].x, 15900.307088)
                XCTAssertEqual(settings.viewpoints[0].y, 4851.879536)
                XCTAssertNil(settings.viewpoints[0].z, "z should be nil when it's not set")
                XCTAssertEqual(settings.viewpoints[0].name, "x20000y-8000")

                XCTAssertEqual(settings.viewpoints[1].x, -9099.692912)
                XCTAssertEqual(settings.viewpoints[1].y, -23148.120464)
                XCTAssertNil(settings.viewpoints[1].z, "z should be nil when it's not set")
                XCTAssertEqual(settings.viewpoints[1].name, "x-5000y-20000")
                
                XCTAssertEqual(settings.viewpoints[2].x, -99.69291200000043)
                XCTAssertEqual(settings.viewpoints[2].y, 851.8795360000004)
                XCTAssertNil(settings.viewpoints[2].z, "z should be nil when it's not set")
                XCTAssertEqual(settings.viewpoints[2].name, "x4000y4000")
                
                if let anchor = settings.anchors.first {
                    XCTAssertEqual(anchor.x, 0.0)
                    XCTAssertEqual(anchor.y, 0.0)
                    XCTAssertEqual(anchor.z, 0.0)
                    XCTAssertEqual(anchor.coordinate?.latitude, 49.178121)
                    XCTAssertEqual(anchor.coordinate?.longitude, -122.842716)
                }
            } catch {
                XCTFail("Settings init throws an exception with data '\(testString)'")
            }
        }
        
        // Test: Initial Model Scaling = Fit, No viewpoints, geolocated anchor without coordinate
        // {"version":"4","scaling":"fit","anchor":{"latitude":49.178121,"longitude":-122.842716},"viewpoints":[]}
        do
        {
            let testString =
                "{\"version\":\"4\",\"scaling\":\"fit\",\"anchor\":{\"latitude\":49.178121,\"longitude\":-122.842716},\"viewpoints\":[]}"
            do {
                let data = testString.data(using: .utf8)
                XCTAssertNotNil(data, "Invalid test data: \(testString)")
                
                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: [])
                let settings = try Settings(json: jsonDict)
                
                XCTAssertEqual(settings.version, "4", "version should be 4")
                XCTAssertNil(settings.scaling, "scaling should be nil when \"scaling\":\"fit\" is set")
                XCTAssertNil(settings.anchorFeatureType, "anchorFeatureType should be nil")
                XCTAssertNotNil(settings.anchors, "anchors should not be nil by default")
                XCTAssertEqual(settings.anchors.count, 1, "anchors should have 0 entry")
                XCTAssertNotNil(settings.viewpoints, "viewpoints should not be nil by default")
                XCTAssertEqual(settings.viewpoints.count, 0, "viewpoints should have 3 entries")
                if let anchor = settings.anchors.first {
                    XCTAssertEqual(anchor.x, 0.0)
                    XCTAssertEqual(anchor.y, 0.0)
                    XCTAssertEqual(anchor.z, 0.0)
                    XCTAssertEqual(anchor.coordinate?.latitude, 49.178121)
                    XCTAssertEqual(anchor.coordinate?.longitude, -122.842716)
                }
            } catch {
                XCTFail("Settings init throws an exception with data '\(testString)'")
            }
        }
        
        // Test: Initial Model Scaling = Fit, Multiple viewpoints with names, anchor located at the last viewpoint
        // {"version":"4","scaling":"fit","anchor":{"latitude":49.178121,"longitude":-122.842716,"x":-99.69291200000043,"y":851.8795360000004},"viewpoints":[
        //     {"x":15900.307088,"y":4851.879536,"name":"x20000y-8000"},
        //     {"x":-9099.692912,"y":-23148.120464,"name":"x-5000y-20000"},
        //     {"x":-99.69291200000043,"y":851.8795360000004,"name":"x4000y4000"}
        // ]}
        do {
            let testString =
                "{\"version\":\"4\",\"scaling\":\"fit\"," +
                     "\"anchor\":{\"latitude\":49.178121,\"longitude\":-122.842716,\"x\":-99.69291200000043,\"y\":851.8795360000004},\"viewpoints\":[" +
                     "{\"x\":15900.307088,\"y\":4851.879536,\"name\":\"x20000y-8000\"}," +
                     "{\"x\":-9099.692912,\"y\":-23148.120464,\"name\":\"x-5000y-20000\"}," +
                     "{\"x\":-99.69291200000043,\"y\":851.8795360000004,\"name\":\"x4000y4000\"}" +
                "]}"
            do {
                let data = testString.data(using: .utf8)
                XCTAssertNotNil(data, "Invalid test data: \(testString)")
                
                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: [])
                let settings = try Settings(json: jsonDict)
                
                XCTAssertEqual(settings.version, "4", "version should be 4")
                XCTAssertNil(settings.scaling, "scaling should be nil when \"scaling\":\"fit\" is set")
                XCTAssertNil(settings.anchorFeatureType, "anchorFeatureType should be nil")
                XCTAssertNotNil(settings.anchors, "anchors should not be nil by default")
                XCTAssertEqual(settings.anchors.count, 1, "anchors should have 0 entry")
                XCTAssertNotNil(settings.viewpoints, "viewpoints should not be nil by default")
                XCTAssertEqual(settings.viewpoints.count, 3, "viewpoints should have 3 entries")

                XCTAssertEqual(settings.viewpoints[0].x, 15900.307088)
                XCTAssertEqual(settings.viewpoints[0].y, 4851.879536)
                XCTAssertNil(settings.viewpoints[0].z, "z should be nil when it's not set")
                XCTAssertEqual(settings.viewpoints[0].name, "x20000y-8000")

                XCTAssertEqual(settings.viewpoints[1].x, -9099.692912)
                XCTAssertEqual(settings.viewpoints[1].y, -23148.120464)
                XCTAssertNil(settings.viewpoints[1].z, "z should be nil when it's not set")
                XCTAssertEqual(settings.viewpoints[1].name, "x-5000y-20000")
                
                XCTAssertEqual(settings.viewpoints[2].x, -99.69291200000043)
                XCTAssertEqual(settings.viewpoints[2].y, 851.8795360000004)
                XCTAssertNil(settings.viewpoints[2].z, "z should be nil when it's not set")
                XCTAssertEqual(settings.viewpoints[2].name, "x4000y4000")
                
                if let anchor = settings.anchors.first {
                    XCTAssertEqual(anchor.x, -99.69291200000043)
                    XCTAssertEqual(anchor.y, 851.8795360000004)
                    XCTAssertEqual(anchor.z, 0.0)
                    XCTAssertEqual(anchor.coordinate?.latitude, 49.178121)
                    XCTAssertEqual(anchor.coordinate?.longitude, -122.842716)
                }
            } catch {
                XCTFail("Settings init throws an exception with data '\(testString)'")
            }
        }
        
        // Test: Initial Model Scaling = Fit, Multiple viewpoints with names, anchor not located at any of the viewpoints
        // {"version":"4","scaling":"fit","anchor":{"latitude":49.178121,"longitude":-122.842716,"x":900.3070879999996,"y":1851.8795360000004},"viewpoints":[
        //     {"x":15900.307088,"y":4851.879536,"name":"x20000y-8000"},
        //     {"x":-9099.692912,"y":-23148.120464,"name":"x-5000y-20000"},
        //     {"x":-99.69291200000043,"y":851.8795360000004,"name":"x4000y4000"}
        // ]}
        do {
            let testString =
                "{\"version\":\"4\",\"scaling\":\"fit\"," +
                     "\"anchor\":{\"latitude\":49.178121,\"longitude\":-122.842716,\"x\":900.3070879999996,\"y\":1851.8795360000004},\"viewpoints\":[" +
                     "{\"x\":15900.307088,\"y\":4851.879536,\"name\":\"x20000y-8000\"}," +
                     "{\"x\":-9099.692912,\"y\":-23148.120464,\"name\":\"x-5000y-20000\"}," +
                     "{\"x\":-99.69291200000043,\"y\":851.8795360000004,\"name\":\"x4000y4000\"}" +
                "]}"
            do {
                let data = testString.data(using: .utf8)
                XCTAssertNotNil(data, "Invalid test data: \(testString)")
                
                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: [])
                let settings = try Settings(json: jsonDict)
                
                XCTAssertEqual(settings.version, "4", "version should be 4")
                XCTAssertNil(settings.scaling, "scaling should be nil when \"scaling\":\"fit\" is set")
                XCTAssertNil(settings.anchorFeatureType, "anchorFeatureType should be nil")
                XCTAssertNotNil(settings.anchors, "anchors should not be nil by default")
                XCTAssertEqual(settings.anchors.count, 1, "anchors should have 0 entry")
                XCTAssertNotNil(settings.viewpoints, "viewpoints should not be nil by default")
                XCTAssertEqual(settings.viewpoints.count, 3, "viewpoints should have 3 entries")

                XCTAssertEqual(settings.viewpoints[0].x, 15900.307088)
                XCTAssertEqual(settings.viewpoints[0].y, 4851.879536)
                XCTAssertNil(settings.viewpoints[0].z, "z should be nil when it's not set")
                XCTAssertEqual(settings.viewpoints[0].name, "x20000y-8000")

                XCTAssertEqual(settings.viewpoints[1].x, -9099.692912)
                XCTAssertEqual(settings.viewpoints[1].y, -23148.120464)
                XCTAssertNil(settings.viewpoints[1].z, "z should be nil when it's not set")
                XCTAssertEqual(settings.viewpoints[1].name, "x-5000y-20000")
                
                XCTAssertEqual(settings.viewpoints[2].x, -99.69291200000043)
                XCTAssertEqual(settings.viewpoints[2].y, 851.8795360000004)
                XCTAssertNil(settings.viewpoints[2].z, "z should be nil when it's not set")
                XCTAssertEqual(settings.viewpoints[2].name, "x4000y4000")
                
                if let anchor = settings.anchors.first {
                    XCTAssertEqual(anchor.x, 900.3070879999996)
                    XCTAssertEqual(anchor.y, 1851.8795360000004)
                    XCTAssertEqual(anchor.z, 0.0)
                    XCTAssertEqual(anchor.coordinate?.latitude, 49.178121)
                    XCTAssertEqual(anchor.coordinate?.longitude, -122.842716)
                }
            } catch {
                XCTFail("Settings init throws an exception with data '\(testString)'")
            }
        }
        
        // Test: Initial Model Scaling = Fit, Multiple viewpoints with names, anchor with z
        // {"version":"4","scaling":"fit","anchor":{"latitude":49.178121,"longitude":-122.842716,"x":-99.69291200000043,"y":851.8795360000004,"z":7264},"viewpoints":[
        //     {"x":15900.307088,"y":4851.879536,"name":"x20000y-8000"},
        //     {"x":-9099.692912,"y":-23148.120464,"name":"x-5000y-20000"},
        //     {"x":-99.69291200000043,"y":851.8795360000004,"name":"x4000y4000"}
        // ]}
        do {
            let testString =
                "{\"version\":\"4\",\"scaling\":\"fit\"," +
                     "\"anchor\":{\"latitude\":49.178121,\"longitude\":-122.842716,\"x\":-99.69291200000043,\"y\":851.8795360000004,\"z\":7264},\"viewpoints\":[" +
                     "{\"x\":15900.307088,\"y\":4851.879536,\"name\":\"x20000y-8000\"}," +
                     "{\"x\":-9099.692912,\"y\":-23148.120464,\"name\":\"x-5000y-20000\"}," +
                     "{\"x\":-99.69291200000043,\"y\":851.8795360000004,\"name\":\"x4000y4000\"}" +
                "]}"
            do {
                let data = testString.data(using: .utf8)
                XCTAssertNotNil(data, "Invalid test data: \(testString)")
                
                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: [])
                let settings = try Settings(json: jsonDict)
                
                XCTAssertEqual(settings.version, "4", "version should be 4")
                XCTAssertNil(settings.scaling, "scaling should be nil when \"scaling\":\"fit\" is set")
                XCTAssertNil(settings.anchorFeatureType, "anchorFeatureType should be nil")
                XCTAssertNotNil(settings.anchors, "anchors should not be nil by default")
                XCTAssertEqual(settings.anchors.count, 1, "anchors should have 0 entry")
                XCTAssertNotNil(settings.viewpoints, "viewpoints should not be nil by default")
                XCTAssertEqual(settings.viewpoints.count, 3, "viewpoints should have 3 entries")

                XCTAssertEqual(settings.viewpoints[0].x, 15900.307088)
                XCTAssertEqual(settings.viewpoints[0].y, 4851.879536)
                XCTAssertNil(settings.viewpoints[0].z, "z should be nil when it's not set")
                XCTAssertEqual(settings.viewpoints[0].name, "x20000y-8000")

                XCTAssertEqual(settings.viewpoints[1].x, -9099.692912)
                XCTAssertEqual(settings.viewpoints[1].y, -23148.120464)
                XCTAssertNil(settings.viewpoints[1].z, "z should be nil when it's not set")
                XCTAssertEqual(settings.viewpoints[1].name, "x-5000y-20000")
                
                XCTAssertEqual(settings.viewpoints[2].x, -99.69291200000043)
                XCTAssertEqual(settings.viewpoints[2].y, 851.8795360000004)
                XCTAssertNil(settings.viewpoints[2].z, "z should be nil when it's not set")
                XCTAssertEqual(settings.viewpoints[2].name, "x4000y4000")
                
                if let anchor = settings.anchors.first {
                    XCTAssertEqual(anchor.x, -99.69291200000043)
                    XCTAssertEqual(anchor.y, 851.8795360000004)
                    XCTAssertEqual(anchor.z, 7264)
                    XCTAssertEqual(anchor.coordinate?.latitude, 49.178121)
                    XCTAssertEqual(anchor.coordinate?.longitude, -122.842716)
                }
            } catch {
                XCTFail("Settings init throws an exception with data '\(testString)'")
            }
        }
        
        // Test: Initial Model Scaling = Fit, Multiple 3D viewpoints with names, anchor with z
        // {"version":"4","scaling":"fit","anchor":{"latitude":49.178121,"longitude":-122.842716,"x":-99.69291200000043,"y":851.8795360000004,"z":7264},"viewpoints":[
        //     {"x":15900.307088,"y":4851.879536, "z":1, "name":"x20000y-8000"},
        //     {"x":-9099.692912,"y":-23148.120464, "z":2, "name":"x-5000y-20000"},
        //     {"x":-99.69291200000043,"y":851.8795360000004, "z":3, "name":"x4000y4000"}
        // ]}
        do {
            let testString =
                "{\"version\":\"4\",\"scaling\":\"fit\"," +
                     "\"anchor\":{\"latitude\":49.178121,\"longitude\":-122.842716,\"x\":-99.69291200000043,\"y\":851.8795360000004,\"z\":7264},\"viewpoints\":[" +
                     "{\"x\":15900.307088,\"y\":4851.879536,\"z\":1,\"name\":\"x20000y-8000\"}," +
                     "{\"x\":-9099.692912,\"y\":-23148.120464,\"z\":2,\"name\":\"x-5000y-20000\"}," +
                     "{\"x\":-99.69291200000043,\"y\":851.8795360000004,\"z\":3,\"name\":\"x4000y4000\"}" +
                "]}"
            do {
                let data = testString.data(using: .utf8)
                XCTAssertNotNil(data, "Invalid test data: \(testString)")
                
                let jsonDict = try JSONSerialization.jsonObject(with: data!, options: [])
                let settings = try Settings(json: jsonDict)
                
                XCTAssertEqual(settings.version, "4", "version should be 4")
                XCTAssertNil(settings.scaling, "scaling should be nil when \"scaling\":\"fit\" is set")
                XCTAssertNil(settings.anchorFeatureType, "anchorFeatureType should be nil")
                XCTAssertNotNil(settings.anchors, "anchors should not be nil by default")
                XCTAssertEqual(settings.anchors.count, 1, "anchors should have 0 entry")
                XCTAssertNotNil(settings.viewpoints, "viewpoints should not be nil by default")
                XCTAssertEqual(settings.viewpoints.count, 3, "viewpoints should have 3 entries")

                XCTAssertEqual(settings.viewpoints[0].x, 15900.307088)
                XCTAssertEqual(settings.viewpoints[0].y, 4851.879536)
                XCTAssertEqual(settings.viewpoints[0].z, 1)
                XCTAssertEqual(settings.viewpoints[0].name, "x20000y-8000")

                XCTAssertEqual(settings.viewpoints[1].x, -9099.692912)
                XCTAssertEqual(settings.viewpoints[1].y, -23148.120464)
                XCTAssertEqual(settings.viewpoints[1].z, 2)
                XCTAssertEqual(settings.viewpoints[1].name, "x-5000y-20000")
                
                XCTAssertEqual(settings.viewpoints[2].x, -99.69291200000043)
                XCTAssertEqual(settings.viewpoints[2].y, 851.8795360000004)
                XCTAssertEqual(settings.viewpoints[2].z, 3)
                XCTAssertEqual(settings.viewpoints[2].name, "x4000y4000")
                
                if let anchor = settings.anchors.first {
                    XCTAssertEqual(anchor.x, -99.69291200000043)
                    XCTAssertEqual(anchor.y, 851.8795360000004)
                    XCTAssertEqual(anchor.z, 7264)
                    XCTAssertEqual(anchor.coordinate?.latitude, 49.178121)
                    XCTAssertEqual(anchor.coordinate?.longitude, -122.842716)
                }
            } catch {
                XCTFail("Settings init throws an exception with data '\(testString)'")
            }
        }
    }
}
