//
//  ToolbarViewTests.swift
//
//  Created by JechtSh0t on 8/21/21.
//  Copyright © 2021 Brook Street Games. All rights reserved.
//

import Testing
import UIKit
@testable import BSGToolbarView

@MainActor
struct ToolbarViewTests {
    
    // MARK: - Properties -
    
    private var basicToolbarView: ToolbarView!
    
    // MARK: - Initializers -
    
    init() {
        let tools = ["doc", "folder", "highlighter", "trash"].map { Tool(id: $0, image: UIImage(systemName: $0)) }
        basicToolbarView = ToolbarView(tools: tools)
    }
}

// MARK: - Initializers -

extension ToolbarViewTests {
    
    ///
    /// Test initializing with a frame.
    ///
    @Test private func testFrameInitializer() {
        let tools = ["doc", "folder", "highlighter", "trash"].map { Tool(id: $0, image: UIImage(systemName: $0)) }
        let toolbarView = ToolbarView(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        toolbarView.tools = tools
        
        #expect(toolbarView.tools.count == 4)
        #expect(toolbarView.activeTools.count == 0)
        #expect(toolbarView.frame == CGRect(x: 0, y: 0, width: 320, height: 40))
    }
    
    ///
    /// Test initializing with an array of tools.
    ///
    @Test private func testToolInitializer() {
        let tools = ["doc", "folder", "highlighter", "trash"].map { Tool(id: $0, image: UIImage(systemName: $0)) }
        let toolbarView = ToolbarView(tools: tools)
        
        #expect(toolbarView.tools.count == 4)
        #expect(toolbarView.activeTools.count == 0)
        #expect(toolbarView.frame == CGRect.zero)
    }
}

// MARK: - Activation -

extension ToolbarViewTests {
    
    ///
    /// Test activating a tool.
    ///
    @Test private func testActivation() {
        #expect(basicToolbarView.activateTool(withIdentifier: "doc"))
        #expect(!basicToolbarView.activateTool(withIdentifier: "fakeTool"))
    }
    
    ///
    /// Test deactivating a tool.
    ///
    @Test private func testDeactivation() {
        basicToolbarView.activateTool(withIdentifier: "doc")
        basicToolbarView.deactivateTool(withIdentifier: "doc")
        
        #expect(basicToolbarView.activeTools.count == 0)
    }
}

// MARK: - Selection Mode -

extension ToolbarViewTests {
    
    ///
    /// Test the *.single* value of *selectionMode*.
    ///
    @Test private func testSingleSelection() {
        basicToolbarView.selectionMode = .single
        basicToolbarView.activateTool(withIdentifier: "doc")
        basicToolbarView.activateTool(withIdentifier: "folder")
        #expect(basicToolbarView.activeTools.map({ $0.id }) == ["folder"])
        
        basicToolbarView.activateTool(withIdentifier: "trash")
        #expect(basicToolbarView.activeTools.map({ $0.id }) == ["trash"])
    }
    
    ///
    /// Test the *.singleLock* value of *selectionMode*.
    ///
    @Test private func testSingleLockSelection() {
        basicToolbarView.selectionMode = .singleLock
        basicToolbarView.activateTool(withIdentifier: "doc")
        
        #expect(basicToolbarView.activeTools.map({ $0.id }) == ["doc"])
        #expect(!basicToolbarView.activateTool(withIdentifier: "folder"))
        #expect(basicToolbarView.activeTools.map({ $0.id }) == ["doc"])
    }
    
    ///
    /// Test the *.multiple* value of *selectionMode*.
    ///
    @Test private func testMultipleSelection() {
        basicToolbarView.selectionMode = .multiple
        basicToolbarView.activateTool(withIdentifier: "doc")
        basicToolbarView.activateTool(withIdentifier: "folder")
        basicToolbarView.activateTool(withIdentifier: "highlighter")
        basicToolbarView.activateTool(withIdentifier: "trash")
        
        #expect(basicToolbarView.activeTools.count == 4)
    }
}
