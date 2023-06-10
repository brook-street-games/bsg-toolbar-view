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
    /// The frame of *toolbarView* in the horizontal position.
    private var horizontalFrame: CGRect { return CGRect(x: 0, y: 0, width: canvasView.bounds.width, height: 50) }
    /// The frame of *toolbarView* in the vertical position.
    private var verticalFrame: CGRect { return CGRect(x: 0, y: 0, width: 50, height: canvasView.bounds.height) }
    
    // MARK: - UI -
    
    /// The area that hosts *toolbarView*
    @IBOutlet private weak var canvasView: UIView!
    
    // MARK: - Setup -
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        createToolbar()
    }

    ///
    /// Creates the horizontal toolbar.
    ///
    private func createToolbar() {
        
        let tools = ["doc", "folder", "highlighter", "trash"].map { Tool(id: $0, image: UIImage(systemName: $0)) }
        toolbarView = ToolbarView(tools: tools)
        toolbarView.delegate = self
        toolbarView.frame = horizontalFrame
		
        canvasView.addSubview(toolbarView)
    }
}

// MARK: - Toolbar Delegate -

extension SampleViewController: ToolbarViewDelegate {
	
    func toolbarView(_ view: ToolbarView, didChangeStatusOf tool: Tool, to newStatus: ToolStatus) {
        debugPrint("Changed status of \(tool.id) to \(newStatus.rawValue)")
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
    
    @IBAction private func axisChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            toolbarView.axis = .horizontal
            toolbarView.frame = horizontalFrame
        case 1:
            toolbarView.axis = .vertical
            toolbarView.frame = verticalFrame
            
        default: break
        }
    }
}
