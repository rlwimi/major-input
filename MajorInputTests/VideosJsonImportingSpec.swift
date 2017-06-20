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
        json = JSON(data: data)
      }

      it("contains 686 sessions") {
        let sessions = json.arrayValue
        expect(sessions.count).to(equal(686))
      }

      it("deserializes sessions") {
        let sessions = json.arrayValue.flatMap(Session.init(json:))
        expect(sessions.count).to(equal(574)) // all - 2012 sessions = 686 - 112 = 574
      }
    }
  }
}
