import Quick
import Nimble
@testable import MajorInput

class CaptionSpec: QuickSpec {

  override func spec() {
    let session = Session(conference: .wwdc,
                          description: "Media playback just got easier and more powerful with the introduction of AVKit on iOS. Hear how AVKit provides view-level services that give you access to the modern media capabilities of AV Foundation. Learn the best practices for playing audiovisual media on iOS and OS X.",
                          downloadHD: URL(string: "http://devstreaming.apple.com/videos/wwdc/2014/503xx50xm4n63qe/503/503_sd_mastering_modern_media_playback.mov")!,
                          downloadSD: URL(string: "http://devstreaming.apple.com/videos/wwdc/2014/503xx50xm4n63qe/503/503_hd_mastering_modern_media_playback.mov")!,
                          duration: nil,
                          focuses: [.macOS, .iOS],
                          image: URL(string: "http://devstreaming.apple.com/videos/wwdc/thumbnails/d20ft1ql/2014/503/503_shelf.jpg"),
                          number: "503",
                          title: "Mastering Modern Media Playback",
                          track: .media,
                          year: "2014")

    describe("CaptionsLoader") {

      var captions: [Caption]!

      beforeEach {

        //  WEBVTT
        //  X-TIMESTAMP-MAP=MPEGTS:181083,LOCAL:00:00:00.000
        //
        //  00:00:11.616 --> 00:00:14.186 A:middle
        //  &gt;&gt; Welcome to "Mastering
        //  Modern Media Playback".
        // ...
        //  00:00:27.346 --> 00:00:29.846 A:middle
        //  The goal of this session
        //  is to show you how easy
        // ...
        //  00:45:37.516 --> 00:45:42.480 A:middle
        //  [ Applause ]

        captions = CaptionsLoader(forSession: session.number, from: session.year)?.captions ?? []
      }

      it("loads raw captions") {

        expect(captions.count).to(equal(898))

        let first = captions.first!
        expect(first.text).to(equal(">> Welcome to \"Mastering Modern Media Playback\"."))
        expect(first.start).to(equal(TimeInterval(11.616)))
        expect(first.end).to(equal(TimeInterval(14.186)))

        let caption = captions[6]

        expect(caption.text).to(equal("The goal of this session is to show you how easy"))
        expect(caption.start).to(equal(TimeInterval(27.346)))
        expect(caption.end).to(equal(TimeInterval(29.846)))

        let last = captions.last!

        expect(last.text).to(equal("[ Applause ]"))
        expect(last.start).to(equal(TimeInterval(45 * 60 + 37.516)))
        expect(last.end).to(equal(TimeInterval(45 * 60 + 42.48)))
      }
    }

    describe("merging time range") {

      var merged: Caption!

      beforeEach {
        let first = Caption(start: TimeInterval(0), end: TimeInterval(1), text: "This is a sentence,")
        let second = Caption(start: TimeInterval(1), end: TimeInterval(2), text: "broken for you.")
        merged = first.merging(second)
      }

      it("selects the earlier start") {
        expect(merged.start).to(equal(TimeInterval(0)))
      }

      it("selects the later end") {
        expect(merged.end).to(equal(TimeInterval(2)))
      }

      it("joins texts with a space") {
        expect(merged.text).to(equal("This is a sentence, broken for you."))
      }
    }

    describe("SessionsService") {

      var rawCaptions: [Caption]!
      var mergedCaptions: [Caption]!

      beforeEach {
        rawCaptions = CaptionsLoader(forSession: session.number, from: session.year)?.captions ?? []
        mergedCaptions = SessionsService().captions(for: session)
      }

      it("does not merge into captions with square-bracketed text") {

        //  00:21:49.516 --> 00:21:55.546 A:middle
        //  [ Applause ]

        expect(mergedCaptions[170]).to(equal(rawCaptions[325]))
      }

      it("merges captions not ending in terminal point") {

        //  00:00:18.856 --> 00:00:21.686 A:middle
        //  And if you are already using
        //  or planning to adopt AVKit
        //
        //  00:00:21.686 --> 00:00:24.496 A:middle
        //  or AVFoundation in your
        //  iOS or OS X applications,
        //
        //  00:00:24.706 --> 00:00:25.916 A:middle
        //  this is the right
        //  session for you.

        let merged = Caption(
          start: TimeInterval(seconds: 18, milliseconds: 856),
          end: TimeInterval(seconds: 25, milliseconds: 916),
          text: "And if you are already using or planning to adopt AVKit or AVFoundation in your iOS or OS X applications, this is the right session for you."
        )
        expect(mergedCaptions[3]).to(equal(merged))
      }
    }
  }
}
