import Quick
import Nimble

class QuickTests: QuickSpec {

  override func spec() {

    describe("Quick") {

      var string: String!

      beforeEach {
        string = "asdf"
      }

      it("tests all the things") {
        expect(string).to(equal("asdf"))
      }
    }
  }
}
