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
    public var tools: [Tool] = [] { didSet { createToolButtons() }}
    /// All tools that are currently active.
    public var activeTools: [Tool] { return tools.filter { activeToolIdentifiers.contains($0.id) }}
    /// The object that handles events triggered by the toolbar.
    public weak var delegate: ToolbarViewDelegate?
    
    // MARK: - Behavior -
    
    /// Controls the layout of tools within the toolbar.
    public var layoutMode: LayoutMode = .block { didSet { createToolButtons() }}
    /// Controls how many tools the user can activate at the same time.
    public var selectionMode: SelectionMode = .single { didSet { createToolButtons() }}
    
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
    
    // MARK: - UI -
    
    private lazy var buttonStackView: UIStackView = {
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)
        
        return stackView
    }()
    
    // MARK: - Initializers -
    
    public init(tools: [Tool]) {
        
        self.tools = tools
        super.init(frame: CGRect.zero)
        layout()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        
        super.init(coder: coder)
        layout()
    }
    
    // MARK: - Setup -
    
    private func layout() {
    
        addConstraint(NSLayoutConstraint(item: buttonStackView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: buttonStackView, attribute: .left, relatedBy: .equal, toItem: self, attribute: .left, multiplier: 1.0, constant: 0))
        addConstraint(NSLayoutConstraint(item: buttonStackView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0))
        
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
        button.setImage(tool.image, for: .normal)
        button.tintColor = toolColor
        button.backgroundColor = toolBackgroundColor
        button.addTarget(self, action: #selector(toolSelected(_:)), for: .touchUpInside)
        
        switch layoutMode {
        case .block:
            button.addConstraint(NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: button, attribute: .height, multiplier: 1.0, constant: 0))
        case .fill:
            let buttonWidth = frame.width / CGFloat(tools.count)
            button.addConstraint(NSLayoutConstraint(item: button, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: buttonWidth))
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
    /// Called when a tool button is pressed.
    ///
    @objc private func toolSelected(_ sender: UIButton) {
        
        // Prevents activation of an additional tool when in single select mode.
        let selectedTool = tools[sender.tag]
        let toolIsActive = activeToolIdentifiers.contains(selectedTool.id)
        
        if toolIsActive {
            activeToolIdentifiers.remove(selectedTool.id)
        } else {
            switch selectionMode {
            // Always allows selection after deselecting active tool.
            case .single:
                activeToolIdentifiers.removeAll()
                update()
            // Allow selection only if no other tools are active
            case .singleLock: if !activeToolIdentifiers.isEmpty { return }
            // Always allows activation
            case .multiple: break
            }
            activeToolIdentifiers.insert(selectedTool.id)
        }
        
        sender.isSelected.toggle()
        update()
        delegate?.toolbarView(self, didChangeStatusOf: tools[sender.tag], status: sender.isSelected)
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
