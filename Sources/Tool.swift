//
//  Tool.swift
//  Created by JechtSh0t on 8/21/21.
//

import UIKit

public enum ToolStatus: String {
    /// The tool is currently active.
    case active
    /// The tool is currently inactive.
    case inactive
}

///
/// Represents a single tool.
///
public struct Tool {
    
    public var id: String
    public var image: UIImage?
    
    public init(id: String, image: UIImage?) {
        
        self.id = id
        self.image = image
    }
}
