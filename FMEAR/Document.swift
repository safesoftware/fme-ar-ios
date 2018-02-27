//
//  Document.swift
//  FMEARBrowser
//
//  Created by Angus Lau on 2017-08-24.
//  Copyright © 2017 Safe Software Inc. All rights reserved.
//

import UIKit

class Document: UIDocument {
    
    override func contents(forType typeName: String) throws -> Any {
        // Encode your document with an instance of NSData or NSFileWrapper
        return Data()
    }
    
    override func load(fromContents contents: Any, ofType typeName: String?) throws {
        // Load your document from contents
    }
}

