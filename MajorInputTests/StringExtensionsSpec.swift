import Quick
import Nimble
@testable import MajorInput

class StringExtensionsSpec: QuickSpec {

  override func spec() {

    describe("progress") {

      var string: String!

      beforeEach {
        string = "asdf"
      }

      it("maps prefix substrings to progress") {
        expect(string.progress(throughRangeOf: "a")).to(equal(0.25))
        expect(string.progress(throughRangeOf: "as")).to(equal(0.5))
        expect(string.progress(throughRangeOf: "asd")).to(equal(0.75))
        expect(string.progress(throughRangeOf: "asdf")).to(equal(1))
      }

      it("maps suffix substrings to progress") {
        expect(string.progress(throughRangeOf: "f")).to(equal(1))
        expect(string.progress(throughRangeOf: "df")).to(equal(1))
        expect(string.progress(throughRangeOf: "sdf")).to(equal(1))
        expect(string.progress(throughRangeOf: "asdf")).to(equal(1))
      }

      it("maps inner substrings to progress") {
        expect(string.progress(throughRangeOf: "sd")).to(equal(0.75))
      }

      it("maps character substrings to progress") {
        expect(string.progress(throughRangeOf: "a")).to(equal(0.25))
        expect(string.progress(throughRangeOf: "s")).to(equal(0.5))
        expect(string.progress(throughRangeOf: "d")).to(equal(0.75))
        expect(string.progress(throughRangeOf: "f")).to(equal(1))
      }
    }

    describe("ends in terminal point") {

      it("recognizes the end of a question") {
        let question = "Would you tell me, please, which way I ought to go from here?"
        expect(question.endsInTerminalPoint).to(beTrue())
      }

      it("recognizes the end of a statement") {
        let statement = "That depends a good deal on where you want to get to."
        expect(statement.endsInTerminalPoint).to(beTrue())
      }
      
      it("recognizes a fragment") {
        let fragment = "I don't much care where,"
        expect(fragment.endsInTerminalPoint).to(beFalse())
      }

      it("recognizes the end of an exclamation") {
        let exclamation = "Then it doesn't matter which way you go!"
        expect(exclamation.endsInTerminalPoint).to(beTrue())
      }

      it("ignores trailing whitespace") {
        let explanation = "so long as I get SOMEWHERE. \n"
        expect(explanation.endsInTerminalPoint).to(beTrue())
      }
    }

    describe("is bracketed") {

      it("recognizes bracketed text") {
        let bracketed = "[ Applause ]"
        expect(bracketed.isBracketed).to(beTrue())
      }

      it("recognizes partially bracketed text") {
        let prefixed = "[ Music"
        expect(prefixed.isBracketed).to(beFalse())

        let suffixed = "Music ]"
        expect(suffixed.isBracketed).to(beFalse())
      }

      it("recognizes unbracketed text") {
        let unbracketed = "Applause"
        expect(unbracketed.isBracketed).to(beFalse())
      }

      it("ignores leading whitespace") {
        let leading = "\t[ Applause ]"
        expect(leading.isBracketed).to(beTrue())
      }

      it("ignores trailing whitespace") {
        let trailing = "[ Applause ]\n"
        expect(trailing.isBracketed).to(beTrue())
      }
    }
  }
}
