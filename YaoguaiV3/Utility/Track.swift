//
//  Track.swift
//  YaoguaiV3
//
//  Created by Charles Zhao on 3/10/2024.
//

import Foundation

func readablePath(from fullPath: String) -> String {
	// Define the project folder name (e.g., "YaoguaiV3")
	let projectFolder = "YaoguaiV3"
	
	// Split the path by the project folder name and rejoin starting from the second occurrence
	let components = fullPath.components(separatedBy: projectFolder)
	
	// Ensure we have at least two components and return the desired part
	if components.count > 2 {
		return projectFolder + components[2] // Rebuild path from second occurrence
	} else if components.count == 2 {
		return projectFolder + components[1]
	}
	
	// Fallback: Return the full path if we don't find the project name
	return fullPath
}

public func track(_ message: String, file: String = #file, function: String = #function, line: Int = #line ) {
	print("\(message).  Called from \(function) \(readablePath(from: file)):\(line)")
}
