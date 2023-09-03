// swift-tools-version: 5.9

import PackageDescription

let package = Package(
	name: "AppleConnect",
	platforms: [.macOS(.v10_15), .iOS(.v13), .watchOS(.v7), .tvOS(.v13)],
	products: [
		.library(
			name: "AppleConnect",
			targets: ["AppleConnect"])
	],
	targets: [
		.target(
			name: "AppleConnect"),
		.testTarget(
			name: "AppleConnectTests",
			dependencies: ["AppleConnect"]),
	]
)
