//
//  SampleViewController.swift
//  Sample
//
//  Created by JechtSh0t on 8/21/21.
//

import UIKit
import BSGToolbarView

///
/// Sample area to explore *BSGToolbarView* configuration options.
///
final class SampleViewController: UIViewController {
    
    // MARK: - Properties -
    
    /// The toolbar
    private var toolbarView: ToolbarView!
    
    // MARK: - UI -
    
    /// The area that hosts *toolbarView*
    @IBOutlet private weak var canvasView: UIView!
    
    // MARK: - Setup -
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        createToolbar()
    }

    ///
    /// Creates the toolbar.
    ///
    private func createToolbar() {
        
        let tools = ["doc", "folder", "highlighter", "trash"].map { Tool(id: $0, image: UIImage(systemName: $0)) }
        toolbarView = ToolbarView(tools: tools)
        toolbarView.frame = CGRect(x: 0, y: (canvasView.bounds.height / 2) - 20, width: view.bounds.width - 40, height: 40)
        toolbarView.toolColor = .gray
        toolbarView.activeToolColor = .green
        toolbarView.selectionMode = .single
        canvasView.addSubview(toolbarView)
    }
}

// MARK: - Controls -

extension SampleViewController {
    
    @IBAction private func layoutModeChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0: toolbarView.layoutMode = .block
        case 1: toolbarView.layoutMode = .fill
        default: break
        }
    }
    
    @IBAction private func selectionModeChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0: toolbarView.selectionMode = .single
        case 1: toolbarView.selectionMode = .singleLock
        case 2: toolbarView.selectionMode = .multiple
        default: break
        }
    }
}
