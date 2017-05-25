import Quick
import Nimble
import SwiftyJSON
@testable import MajorInput

class VideosJsonImportingSpec: QuickSpec {

  override func spec() {

    describe("Sessions data") {

      var json: JSON!

      beforeEach {
        let url = Bundle.main.url(forResource: "videos.json", withExtension: nil)!
        let data = try! Data(contentsOf: url)
        json = JSON(data: data)
      }

      it("is known by timestamp") {
        let timestamp = json["updated"].stringValue
        expect(timestamp).to(equal("2016-07-12T10:43:33-07:00"))
      }

      it("contains 550 sessions") {
        let sessions = json["sessions"].arrayValue
        expect(sessions.count).to(equal(550))
      }

      it("deserializes sessions") {
        let sessions = json["sessions"].arrayValue.flatMap(Session.init(json:))
        expect(sessions.count).to(equal(437)) // all - 2012 sessions = 550 - 113 = 437
      }
    }
  }
}
