//
//  ToolbarViewTests.swift
//
//  Created by JechtSh0t on 8/21/21.
//

import XCTest
@testable import BSGToolbarView

final class ToolbarViewTests: XCTestCase {
    
    func testFrameInitializer() {
        
        let tools = ["doc", "folder", "highlighter", "trash"].map { Tool(id: $0, image: UIImage(systemName: $0)) }
        let toolbarView = ToolbarView(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        toolbarView.tools = tools
        
        XCTAssertEqual(toolbarView.tools.count, 4)
        XCTAssertEqual(toolbarView.activeTools.count, 0)
        XCTAssertEqual(toolbarView.frame, CGRect(x: 0, y: 0, width: 320, height: 40))
    }
    
    func testToolInitializer() {
        
        let tools = ["doc", "folder", "highlighter", "trash"].map { Tool(id: $0, image: UIImage(systemName: $0)) }
        let toolbarView = ToolbarView(tools: tools)
        
        XCTAssertEqual(toolbarView.tools.count, 4)
        XCTAssertEqual(toolbarView.activeTools.count, 0)
        XCTAssertEqual(toolbarView.frame, CGRect.zero)
    }
}

