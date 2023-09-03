import XCTest

@testable import AppleConnect

final class AppleConnectTests: XCTestCase {
	static let serviceType = "_appleconnecttest._tcp"

	// Generated randomly.
	static let key = Data([0xbb, 0x62, 0x04, 0x37, 0x86, 0x6e, 0x03, 0x45])

	static let clientData = [
		Data([1]),
		AppleConnectTests.key,
		Data([UInt8](repeating: 0xfe, count: 100_000)),
	]

	static let serverData = [
		Data([2]),
		AppleConnectTests.key,
		Data([UInt8](repeating: 0xfd, count: 100_000)),
	]

	func testServer() async throws {
		let connection = try await Connection(connection: Connection.advertise(forServiceType: Self.serviceType, key: Self.key).first { _ in true }!)
		try await Self.verify(sending: Self.serverData, receiving: Self.clientData, on: connection)
		connection.close()
	}

	func testClient() async throws {
		let connection = try await Connection(endpoint: Connection.endpoints(forServiceType: Self.serviceType).first { !$0.isEmpty }!.first!, key: Self.key)
		try await Self.verify(sending: Self.clientData, receiving: Self.serverData, on: connection)
		connection.close()
	}

	static func verify(sending data: [Data], receiving: [Data], on connection: Connection) async throws {
		let send = Task {
			for d in data {
				try await connection.send(data: d)
			}
		}
		let receive = Task {
			var results = [Data]()
			for try await data in connection.data {
				results.append(data)
				if results.count == receiving.count {
					break
				}
			}
			return results
		}
		let results = try await (send.value, receive.value).1
		XCTAssertEqual(results, receiving)
	}
}
