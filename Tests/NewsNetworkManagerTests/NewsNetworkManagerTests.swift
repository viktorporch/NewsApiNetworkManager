import XCTest
@testable import NewsNetworkManager

final class NewsNetworkManagerTests: XCTestCase {
    let sut: NetworkManager = NetworkManagerClient(key: "d173108dad1740f5aadc988b463ace28")
    
    func testHeadlines() async throws {
        let result = await sut.getHeadlines(query: nil)
        XCTAssertNotNil(try? result.get(), "failed to get headlines")
    }
    
    func testSources() async throws {
        let result = await sut.getSources()
        XCTAssertNotNil(try? result.get(), "failed to get sources")
    }
    
    func testArticles() async throws {
        let result = await sut.getArticles(q: "election")
        XCTAssertNotNil(try? result.get(), "failed to get articles")
    }
}
