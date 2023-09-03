import Foundation
import Network

class AppleConnectProtocol: NWProtocolFramerImplementation {
	struct Header {
		static let headerSize = MemoryLayout<UInt64>.size
		let length: UInt64

		var data: Data {
			Data(
				(0..<MemoryLayout<UInt64>.size).map {
					UInt8(length >> ($0 * 8) & 0xff)
				}.reversed())
		}
	}

	static let definition = NWProtocolFramer.Definition(implementation: AppleConnectProtocol.self)

	static var label: String = "AppleConnect"

	required init(framer: NWProtocolFramer.Instance) {
	}

	func start(framer: NWProtocolFramer.Instance) -> NWProtocolFramer.StartResult {
		.ready
	}

	func wakeup(framer: NWProtocolFramer.Instance) {
	}

	func stop(framer: NWProtocolFramer.Instance) -> Bool {
		true
	}

	func cleanup(framer: NWProtocolFramer.Instance) {
	}

	func handleInput(framer: NWProtocolFramer.Instance) -> Int {
		while true {
			var header: Header!
			let success = framer.parseInput(minimumIncompleteLength: Header.headerSize, maximumLength: Header.headerSize) { buffer, _ in
				guard let buffer = buffer,
					buffer.count >= Header.headerSize
				else {
					return 0
				}
				header = Header(buffer: buffer)
				return Header.headerSize
			}
			guard success,
				framer.deliverInputNoCopy(length: Int(header.length), message: .init(definition: Self.definition), isComplete: true)
			else {
				return 0
			}
		}
	}

	func handleOutput(framer: NWProtocolFramer.Instance, message: NWProtocolFramer.Message, messageLength: Int, isComplete: Bool) {
		framer.writeOutput(data: Header(length: UInt64(messageLength)).data)
		try! framer.writeOutputNoCopy(length: messageLength)
	}
}

extension AppleConnectProtocol.Header {
	init(buffer: UnsafeMutableRawBufferPointer) {
		length = buffer[buffer.startIndex..<buffer.startIndex.advanced(by: MemoryLayout<UInt64>.size)].reduce(0) {
			return UInt64($0 << 8) | UInt64($1)
		}
	}
}
