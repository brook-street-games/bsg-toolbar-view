//
//  ToolbarView.swift
//
//  Created by JechtSh0t on 8/21/21.
//  Copyright © 2021 Brook Street Games. All rights reserved.
//

import UIKit

// MARK: - Delegate -

public protocol ToolbarViewDelegate: AnyObject {
	
	/// Called to allow custom configuration for tool buttons.
	func toolbarView(_ view: ToolbarView, didCompleteSetupFor tool: Tool, button: UIButton)
    /// Called to allow the delegate a change to stop a tool from changing status.
    func toolbarView(_ view: ToolbarView, shouldChangeStatusOf tool: Tool, to newStatus: ToolStatus) -> Bool
    /// Called when any tool is toggled on or off.
    func toolbarView(_ view: ToolbarView, didChangeStatusOf tool: Tool, to newStatus: ToolStatus)
}

public extension ToolbarViewDelegate {
    
	func toolbarView(_ view: ToolbarView, didCompleteSetupFor tool: Tool, button: UIButton) {}
    func toolbarView(_ view: ToolbarView, shouldChangeStatusOf tool: Tool, to newStatus: ToolStatus) -> Bool { return true }
    func toolbarView(_ view: ToolbarView, didChangeStatusOf tool: Tool, to newStatus: ToolStatus) {}
}

// MARK: - ToolbarView -

///
/// A view that displays tools that can be toggled on or off.
///
public final class ToolbarView: UIView {
    
    // MARK: - Nested Types -
    
    public enum LayoutMode {
        /// Tools will only take up the room they need.
        case block
        /// Tools will expand to fill the toolbar.
        case fill
    }
    
    public enum SelectionAnimation {
        /// Tools will not animate when selected.
        case none
        /// Tools will bounce when selected.
        case bounce
    }
    
    public enum SelectionMode {
        /// Only one tool can be active at a time.
        case single
        /// Only one tool can be active at a time. The tool must be deactivated before another can be activated.
        case singleLock
        /// Multiple tools can be active at once.
        case multiple
    }
    
    // MARK: - Properties -
    
    /// A unique identifier.
    public let id = UUID()
    /// All tools that are displayed.
    public var tools: [Tool] = [] { didSet { setup(resetTools: true) }}
    /// All tools that are currently active.
    public var activeTools: [Tool] { return tools.filter { activeToolIdentifiers.contains($0.id) }}
    /// The object that handles events triggered by the toolbar.
    public weak var delegate: ToolbarViewDelegate?
    
    // MARK: - Behavior -
    
    /// Controls the layout axis. The frame must be adjusted accordingly when changing this property.
    public var axis: NSLayoutConstraint.Axis = .horizontal { didSet { setup(resetTools: false) }}
    /// Controls the layout of tools within the toolbar.
    public var layoutMode: LayoutMode = .block { didSet { setup(resetTools: false) }}
    /// Controls how many tools the user can activate at the same time.
    public var selectionMode: SelectionMode = .single { didSet { setup(resetTools: true) }}
	/// Controls the tool selection animation.
	public var selectionAnimation: SelectionAnimation = .bounce { didSet { setup(resetTools: false) }}
    
    // MARK: - Styling -
    
    /// The tint color of the tool image when inactive.
    public var toolColor: UIColor = .label { didSet { updateTools() }}
    /// The tint color of the tool image when active.
    public var activeToolColor: UIColor = .systemBlue { didSet { updateTools() }}
    /// The background color of the tool when inactive.
    public var toolBackgroundColor: UIColor = .clear { didSet { updateTools() }}
    /// The background color of the tool when active.
    public var activeToolBackgroundColor: UIColor = .clear { didSet { updateTools() }}
    
    // MARK: - Private Properties -
    
    private var activeToolIdentifiers = Set<String>()
    
    // MARK: - Override Properties -
    
    /// Forces recreation of tool buttons when changing.
    public override var frame: CGRect { didSet { setup(resetTools: false) }}
    
    // MARK: - UI -
    
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        return stackView
    }()
    
    // MARK: - Initializers -
    
    public init(tools: [Tool]) {
        // Triggers setup
        self.tools = tools
        super.init(frame: CGRect.zero)
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup(resetTools: true)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup(resetTools: true)
    }
    
    // MARK: - Setup -
    
    ///
    /// Initial setup, or re-setup due to change to a major property.
    ///
    /// - parameter resetTools: If true, *activeToolsIdentifiers* will be cleared.
    ///
    private func setup(resetTools: Bool) {
        clipsToBounds = true
        buttonStackView.axis = axis
        NSLayoutConstraint.deactivate(constraints)
        
        addConstraint(NSLayoutConstraint(item: buttonStackView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: buttonStackView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0))
            
        switch axis {
        case .horizontal: addConstraint(NSLayoutConstraint(item: buttonStackView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0))
        case .vertical: addConstraint(NSLayoutConstraint(item: buttonStackView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0))
        @unknown default: fatalError()
        }
        
        if resetTools { activeToolIdentifiers.removeAll() }
        createToolButtons()
        updateTools()
    }
    
    ///
    /// Empties and refills toolbar with buttons.
    ///
    private func createToolButtons() {
        for button in buttonStackView.subviews { button.removeFromSuperview() }
        
        for (index, tool) in tools.enumerated() {
            let toolButton = createToolButton(for: tool, index: index)
            buttonStackView.addArrangedSubview(toolButton)
			delegate?.toolbarView(self, didCompleteSetupFor: tool, button: toolButton)
        }
    }
    
    ///
    /// Creates a tool button.
    ///
    /// - parameter tool: The tool to create a button for.
    /// - parameter index: The array index of the tool for identification purposes.
    ///
    private func createToolButton(for tool: Tool, index: Int) -> UIButton {
        let button = UIButton()
        button.tag = index
        
        // Size image to fill 50% of the button. This still looks good as the toolbar scales.
        button.setImage(tool.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
		button.adjustsImageWhenHighlighted = false
   
        let insetAmount: CGFloat
        switch axis {
        case .horizontal: insetAmount = bounds.height * 0.25
        case .vertical: insetAmount = bounds.width * 0.25
        @unknown default: insetAmount = 0
        }
        button.contentEdgeInsets = UIEdgeInsets(top: insetAmount, left: insetAmount, bottom: insetAmount, right: insetAmount)
        
        // Tints and colors
        button.tintColor = toolColor
        button.backgroundColor = toolBackgroundColor
		
		if selectionAnimation == .bounce {
			button.addTarget(self, action: #selector(animateBouncePress), for: [.touchDown, .touchDragEnter])
			button.addTarget(self, action: #selector(animateBounceRelease), for: [.touchDragExit, .touchCancel, .touchUpInside, .touchUpOutside])
		}

        button.addTarget(self, action: #selector(toolSelected(_:)), for: .touchUpInside)
        
        // Set up constraints
        switch (layoutMode, axis) {
        
        case (.block, _):
            button.addConstraint(NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: button, attribute: .width, multiplier: 1.0, constant: 0.0))
            
        case (.fill, .horizontal):
            let buttonWidth = frame.width / CGFloat(tools.count)
            button.addConstraint(NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: buttonWidth))
            
        case (.fill, .vertical):
            let buttonHeight = frame.height / CGFloat(tools.count)
            button.addConstraint(NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: buttonHeight))
            
        @unknown default: break
        }
        
        return button
    }
    
    ///
    /// Update button colors to reflect active tools.
    ///
    private func updateTools() {
        for view in buttonStackView.subviews {
            guard let button = view as? UIButton else { continue }
            let isActive = activeToolIdentifiers.contains(tools[button.tag].id)
            button.isSelected = isActive
            button.tintColor = isActive ? activeToolColor : toolColor
            button.backgroundColor = isActive ? activeToolBackgroundColor : toolBackgroundColor
        }
    }
}

// MARK: - Tool Selection -

extension ToolbarView {
    
    ///
    /// Activates a tool.
    /// - note: This method will obey the rule of *selectionMode*.
    ///
    /// - parameter toolIdentifier: The identifier of the tool to activate.
    /// - returns: True if the tool was successfully activated. False if the tool could not be activated.
    ///
    @discardableResult
    public func activateTool(withIdentifier toolIdentifier: String) -> Bool {
        guard let tool = tools.first(where: { $0.id == toolIdentifier }) else { return false }
        let toolIsActive = activeToolIdentifiers.contains(tool.id)
        
        // Gives delegate a change to block activation.
        if let delegate = delegate, delegate.toolbarView(self, shouldChangeStatusOf: tool, to: .active) == false { return false }
        // Checks if the tool is already active.
        guard !toolIsActive else { return true }
        
        switch selectionMode {
        // Always allows selection after deselecting active tool.
        case .single: activeToolIdentifiers.removeAll()
        // Allow selection only if no other tools are active
        case .singleLock: if !activeToolIdentifiers.isEmpty { return false }
        // Always allows activation
        case .multiple: break
        }
        
        activeToolIdentifiers.insert(tool.id)
        updateTools()
        delegate?.toolbarView(self, didChangeStatusOf: tool, to: .active)
        
        return true
    }
    
    ///
    /// Deactivates a tool.
    ///
    /// - parameter toolIdentifier: The identifier of the tool to deactivate.
    /// - returns: True if the tool was successfully deactivated. False if the tool could not be deactivated.
    ///
    @discardableResult
    public func deactivateTool(withIdentifier toolIdentifier: String) -> Bool {
        guard let tool = tools.first(where: { $0.id == toolIdentifier }) else { return false }
        let toolIsActive = activeToolIdentifiers.contains(tool.id)
        
        // Gives delegate a change to block activation.
        if let delegate = delegate, delegate.toolbarView(self, shouldChangeStatusOf: tool, to: .inactive) == false { return false }
        // Checks if the tool is already inactive.
        guard toolIsActive else { return true }
        
        activeToolIdentifiers.remove(toolIdentifier)
        updateTools()
        delegate?.toolbarView(self, didChangeStatusOf: tool, to: .inactive)
        return true
    }
    
    ///
    /// Called when a tool button is pressed.
    ///
    @objc private func toolSelected(_ sender: UIButton) {
        let tool = tools[sender.tag]
        let toolIsActive = activeToolIdentifiers.contains(tool.id)
        
        if toolIsActive {
            deactivateTool(withIdentifier: tool.id)
        } else {
            activateTool(withIdentifier: tool.id)
        }
    }
}
