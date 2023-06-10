# BSGToolbarView

## Overview

A toolbar that displays an array of configurable tools. Includes horizontal and vertical axis, multiple selection, and color customization.

## Installation

### Requirements

+ iOS 13+

#### Swift Package Manager

1. Navigate to ***File->Add Packages***.
3. Enter Package URL: https://github.com/brook-street-games/bsg-toolbar-view.git
3. Select a dependency rule. **Up to Next Major** is recommended.
4. Select a project.
5. Select **Add Package**.

## Usage

```swift
// Import the framework.
import BSGToolbarView

// Create tools. Each tool requires an id and image.
let tools: [Tool] = []

// Create a toolbar.
toolbarView = ToolbarView(tools: tools)
toolbarView.delegate = self

// Add the toolbar to the view hierarchy.
view.addSubview(toolbarView)

// Receive updates when tools change status.
func toolbarView(_ view: ToolbarView, didChangeStatusOf tool: Tool, to newStatus: ToolStatus) {
	// Handle status change.
}
```

## Customization

#### Style

```swift
// Change the tint color of inactive tools.
toolbarView.toolColor = .black
// Change the tint color of active tools.
toolbarView.activeToolColor = .red
// Change the background color of inactive tools.
toolbarView.toolBackgroundColor = .gray
// Change the background color of active tools.
toolbarView.activeToolBackgroundColor = .black
```

#### Behavior

```swift
// Change the axis.
toolbarView.axis = .vertical
// Change the layout mode.
toolbarView.layoutMode = .fill
// Change the selection mode.
toolbarView.selectionMode = .multiple
// Change the selection animation.
toolbarView.selectionAnimation = .none
```

## Author

Brook Street Games LLC
