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
    /// The tool that are currently active.
    public var activeTools: [Tool] { return tools.filter { activeToolIdentifiers.contains($0.id) }}
    /// The object that handles events triggered by the toolbar.
    public weak var delegate: ToolbarViewDelegate?
    
    // MARK: - Behavior -
    
    /// Controls the layout of tools within the toolbar.
    public var layoutMode: LayoutMode = .block { didSet { createToolButtons() }}
    
    // MARK: - Styling -
    
    /// The tint color of the tool image when unselected.
    public var toolColor: UIColor = .black { didSet { update() }}
    /// The tint color of the tool image when selected.
    public var activeToolColor: UIColor = .white { didSet { update() }}
    /// The background color of the tool when unselected.
    public var toolBackgroundColor: UIColor = .clear { didSet { update() }}
    /// The background color of the tool when selected.
    public var activeToolBackgroundColor: UIColor = .clear { didSet { update() }}
    /// Controls how many tools the user can select.
    public var selectionMode: SelectionMode = .single { didSet { createToolButtons() }}
    
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
    /// Update button colors to reflect user selection.
    ///
    private func update() {
        
        for view in buttonStackView.subviews {
            guard let button = view as? UIButton else { continue }
            button.tintColor = button.isSelected ? activeToolColor : toolColor
            button.backgroundColor = button.isSelected ? activeToolBackgroundColor : toolBackgroundColor
        }
    }
}

// MARK: - Tool Selection -

extension ToolbarView {
    
    ///
    /// Called when a tool button is pressed.
    ///
    @objc private func toolSelected(_ sender: UIButton) {
        
        // Prevents selection of an additional tool when in single select mode.
        let selectedTool = tools[sender.tag]
        let toolIsActive = activeToolIdentifiers.contains(selectedTool.id)
        
        if toolIsActive {
            activeToolIdentifiers.remove(selectedTool.id)
        } else {
            if selectionMode == .single && activeTools.count > 0 { return }
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
        /// Only one tool can be selected at a time.
        case single
        /// Multiple tools can be selected at once.
        case multiple
    }
}
