//
//  ToolbarView.swift
//  Created by JechtSh0t on 8/31/21.
//

import UIKit

// MARK: - Delegate -

public protocol ToolbarViewDelegate: AnyObject {
    /// Called when any tool is toggled on or off.
    func toolbarView(_ view: ToolbarView, didChangeStatusOf tool: Tool, status: Bool)
}

// MARK: - ToolbarView -

///
/// A view that displays tools that can be toggled on or off.
///
public final class ToolbarView: UIView {
    
    // MARK: - Properties -
    
    /// All tools that are displayed.
    public var tools: [Tool] = [] { didSet { setup() }}
    /// All tools that are currently active.
    public var activeTools: [Tool] { return tools.filter { activeToolIdentifiers.contains($0.id) }}
    /// The object that handles events triggered by the toolbar.
    public weak var delegate: ToolbarViewDelegate?
    
    // MARK: - Behavior -
    
    /// Controls the layout axis. The frame must be adjusted accordingly when changing this property.
    public var axis: NSLayoutConstraint.Axis = .horizontal { didSet { setup() }}
    /// Controls the layout of tools within the toolbar.
    public var layoutMode: LayoutMode = .block { didSet { setup() }}
    /// Controls how many tools the user can activate at the same time.
    public var selectionMode: SelectionMode = .single { didSet { setup() }}
    
    // MARK: - Styling -
    
    /// The tint color of the tool image when inactive.
    public var toolColor: UIColor = .label { didSet { update() }}
    /// The tint color of the tool image when active.
    public var activeToolColor: UIColor = .green { didSet { update() }}
    /// The background color of the tool when inactive.
    public var toolBackgroundColor: UIColor = .clear { didSet { update() }}
    /// The background color of the tool when active.
    public var activeToolBackgroundColor: UIColor = .clear { didSet { update() }}
    
    // MARK: - Private Properties -
    
    private var activeToolIdentifiers = Set<String>()
    
    // MARK: - Override Properties -
    
    /// Forces recreation of tool buttons when changing.
    public override var frame: CGRect { didSet { setup() }}
    
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
        setup()
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        setup()
    }
    
    // MARK: - Setup -
    
    private func setup() {
    
        buttonStackView.axis = axis
        NSLayoutConstraint.deactivate(constraints)
        
        addConstraint(NSLayoutConstraint(item: buttonStackView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: buttonStackView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0))
            
        switch axis {
        case .horizontal: addConstraint(NSLayoutConstraint(item: buttonStackView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0))
        case .vertical: addConstraint(NSLayoutConstraint(item: buttonStackView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0))
        @unknown default: fatalError()
        }
        
        createToolButtons()
    }
    
    ///
    /// Empties and refills toolbar with buttons.
    ///
    private func createToolButtons() {
        
        activeToolIdentifiers.removeAll()
        for button in buttonStackView.subviews { button.removeFromSuperview() }
        
        for (index, tool) in tools.enumerated() {
            let toolButton = createToolButton(for: tool, index: index)
            buttonStackView.addArrangedSubview(toolButton)
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
        button.setImage(tool.image?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        // Sizes the image to match the height of system images (24). This seems to jive nicely
        let insetAmount: CGFloat = 0//(bounds.height / 2) - 12
        button.contentEdgeInsets = UIEdgeInsets(top: insetAmount, left: insetAmount, bottom: insetAmount, right: insetAmount)
        button.tintColor = toolColor
        button.backgroundColor = toolBackgroundColor
        button.addTarget(self, action: #selector(toolSelected(_:)), for: .touchUpInside)
        
        switch (layoutMode, axis) {
        
        case (.block, _):
            button.addConstraint(NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: button, attribute: .width, multiplier: 1.0, constant: 0.0))
            
        case (.fill, .horizontal):
            let buttonWidth = frame.width / CGFloat(tools.count)
            button.addConstraint(NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: buttonWidth))
            
        case (.fill, .vertical):
            let buttonHeight = frame.height / CGFloat(tools.count)
            button.addConstraint(NSLayoutConstraint(item: button, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: buttonHeight))
            
        @unknown default: fatalError()
        }
        
        return button
    }
    
    ///
    /// Update button colors to reflect active tools.
    ///
    private func update() {
        
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
        update()
        delegate?.toolbarView(self, didChangeStatusOf: tool, status: true)
        
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
        
        guard toolIsActive else { return true }
        
        activeToolIdentifiers.remove(toolIdentifier)
        update()
        delegate?.toolbarView(self, didChangeStatusOf: tool, status: false)
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

// MARK: - Nested Types - {

public extension ToolbarView {
    
    enum LayoutMode {
        /// Tools will only take up the room they need.
        case block
        /// Tools will expand to fill the toolbar.
        case fill
    }
    
    enum SelectionMode {
        /// Only one tool can be active at a time.
        case single
        /// Only one tool can be active at a time. The tool must be deactivated before another can be activated.
        case singleLock
        /// Multiple tools can be active at once.
        case multiple
    }
}
