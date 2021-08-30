# BSGToolbarView

## Description
BSGToolbarView is a configurable toolbar that displays an array of tool passed in by the user. It can be configured horizontally or vertically.

## Requirements

+ iOS 13+

## Installation

### Swift Package Manager

1. File->Swift Packages->Add Package Dependency
2. Select project
3. Add project URL (https://github.com/brook-street-games/bsg-toolbar-view.git) and click Next
4. Select (Version, Up to Next Major, 1.0) and click Next

## Example

```swift
// Creation
let tools = ["doc", "folder", "highlighter", "trash"].map { Tool(id: $0, image: UIImage(systemName: $0)) }
toolbarView = ToolbarView(tools: tools)
toolbarView.delegate = self

// Behavior
toolbarView.axis = .horizontal
toolbarView.layoutMode = .fill
toolbarView.selectionMode = .single

// Styling
toolbarView.backgroundColor = .black
toolbarView.toolColor = .lightGray
toolbarView.activeToolColor = .red
toolbarView.frame = CGRect(x: 0, y: 0, width: canvasView.bounds.width, height: 50)

view.addSubview(toolbarView)
```

![BSGToolbarView](../Example/example.png)

## Sample Project

A sample project is included in the repository. Select the BSGToolbarViewSample target in Xcode to run it.

## Author

Brook Street Games LLC
