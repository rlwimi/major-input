import Quick
import Nimble
import SwiftyJSON
@testable import MajorInput

class VideosJsonImportingSpec: QuickSpec {

  override func spec() {

    describe("Sessions data") {

      var json: JSON!

      beforeEach {
        let url = Bundle.main.url(forResource: "sessions.json", withExtension: nil)!
        let data = try! Data(contentsOf: url)
        json = try! JSON(data: data)
      }

      it("contains 686 sessions") {
        let sessions = json.arrayValue
        expect(sessions.count).to(equal(687))
      }

      it("deserializes sessions") {
        let sessions = json.arrayValue.compactMap(Session.init(json:))
        expect(sessions.count).to(equal(575)) // all - 2012 sessions = 687 - 112 = 574
      }
    }
  }
}
