//
//  ToolbarViewTests.swift
//
//  Created by JechtSh0t on 8/21/21.
//

import XCTest
@testable import BSGToolbarView

final class ToolbarViewTests: XCTestCase {
    
    private var basicToolbarView: ToolbarView!
    
    override func setUp() {
        
        let tools = ["doc", "folder", "highlighter", "trash"].map { Tool(id: $0, image: UIImage(systemName: $0)) }
        basicToolbarView = ToolbarView(tools: tools)
    }
}

// MARK: - Initializers -

extension ToolbarViewTests {
    
    ///
    /// Tests initializing *ToolbarView* with a frame.
    ///
    func testFrameInitializer() {
        
        let tools = ["doc", "folder", "highlighter", "trash"].map { Tool(id: $0, image: UIImage(systemName: $0)) }
        let toolbarView = ToolbarView(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        toolbarView.tools = tools
        
        XCTAssertEqual(toolbarView.tools.count, 4)
        XCTAssertEqual(toolbarView.activeTools.count, 0)
        XCTAssertEqual(toolbarView.frame, CGRect(x: 0, y: 0, width: 320, height: 40))
    }
    
    ///
    /// Tests initializing *ToolbarView* with an array of tools.
    ///
    func testToolInitializer() {
        
        let tools = ["doc", "folder", "highlighter", "trash"].map { Tool(id: $0, image: UIImage(systemName: $0)) }
        let toolbarView = ToolbarView(tools: tools)
        
        XCTAssertEqual(toolbarView.tools.count, 4)
        XCTAssertEqual(toolbarView.activeTools.count, 0)
        XCTAssertEqual(toolbarView.frame, CGRect.zero)
    }
}

// MARK: - Activation -

extension ToolbarViewTests {
    
    ///
    /// Tests activating a tool.
    ///
    func testActivation() {
        
        XCTAssertTrue(basicToolbarView.activateTool(withIdentifier: "doc"))
        XCTAssertFalse(basicToolbarView.activateTool(withIdentifier: "fakeTool"))
    }
    
    ///
    /// Tests deactivating a tool.
    ///
    func testDeactivation() {
        
        basicToolbarView.activateTool(withIdentifier: "doc")
        basicToolbarView.deactivateTool(withIdentifier: "doc")
        
        XCTAssertEqual(basicToolbarView.activeTools.count, 0)
    }
}

// MARK: - Selection Mode -

extension ToolbarViewTests {
    
    ///
    /// Tests the *.single* value of *selectionMode*.
    ///
    func testSingleSelection() {
        
        basicToolbarView.selectionMode = .single
        basicToolbarView.activateTool(withIdentifier: "doc")
        basicToolbarView.activateTool(withIdentifier: "folder")
        XCTAssertEqual(basicToolbarView.activeTools.map({ $0.id }), ["folder"])
        
        basicToolbarView.activateTool(withIdentifier: "trash")
        XCTAssertEqual(basicToolbarView.activeTools.map({ $0.id }), ["trash"])
    }
    
    ///
    /// Tests the *.singleLock* value of *selectionMode*.
    ///
    func testSingleLockSelection() {
        
        basicToolbarView.selectionMode = .singleLock
        basicToolbarView.activateTool(withIdentifier: "doc")
        
        XCTAssertEqual(basicToolbarView.activeTools.map({ $0.id }), ["doc"])
        XCTAssertFalse(basicToolbarView.activateTool(withIdentifier: "folder"))
        XCTAssertEqual(basicToolbarView.activeTools.map({ $0.id }), ["doc"])
    }
    
    ///
    /// Tests the *.multiple* value of *selectionMode*.
    ///
    func testMultipleSelection() {
        
        basicToolbarView.selectionMode = .multiple
        basicToolbarView.activateTool(withIdentifier: "doc")
        basicToolbarView.activateTool(withIdentifier: "folder")
        basicToolbarView.activateTool(withIdentifier: "highlighter")
        basicToolbarView.activateTool(withIdentifier: "trash")
        
        XCTAssertEqual(basicToolbarView.activeTools.count, 4)
    }
}

