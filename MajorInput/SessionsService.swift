import Foundation
import SwiftyJSON

final class SessionsService {

  let byConference: SortDescriptor<Session> = sortDescriptor(property: { $0.conference.rawValue })
  let byYearDescending: SortDescriptor<Session> = sortDescriptor(property: { $0.year }, ascending: false)
  let byNumber: SortDescriptor<Session> = sortDescriptor(property: { $0.number })

  var defaultSortDescriptors: SortDescriptor<Session> {
    return combine(sortDescriptors: [byConference, byYearDescending, byNumber])
  }

  lazy var sessions: [Session] = {
    let url = Bundle.main.url(forResource: "videos.json", withExtension: nil)!
    let data = try! Data(contentsOf: url)
    let json = JSON(data: data)
    let sessions = json["sessions"].arrayValue
      .flatMap(Session.init(json:))
      .sorted(by: self.defaultSortDescriptors)

    return sessions
  }()

  func captions(for session: Session) -> [Caption] {
    return captions(withContentsOf: session.localVttUrl).sentencifying
  }

  func captions(withContentsOf url: URL) -> [Caption] {
    guard let vtt = try? String(contentsOf: url)
      else { return [] }

    // TODO: Swiftify this literal translation from Objective-C

    var captions: [Caption] = []

    // Exclusively for recognizing repeated subtitles (we see them, not sure why)
    var previous: Caption?

    // Collects `Caption` line-by-line
    var current: Caption?

    vtt.enumerateLines { line, _ in
      if current != nil {
        if line.isEmpty {
          // Current caption is complete. Remove if redundant. Reset machinery.
          if previous == nil || previous! != current {
            captions.append(current!)
            previous = current
          }
          current = nil
        } else {
          if current!.text.isEmpty {
            current!.text = line.htmlUnescape()
          } else {
            current!.text = "\(current!.text) \(line)"
          }
        }
      } else {
        let regexString = "^(\\d\\d):(\\d\\d):(\\d\\d)[,.](\\d\\d\\d) --> (\\d\\d):(\\d\\d):(\\d\\d)[,.](\\d\\d\\d).*$"
        let regex = try! NSRegularExpression(pattern: regexString)
        let result = regex.firstMatch(in: line, range: NSRange(location: 0, length: line.utf16.count))
        if let result = result {
          let startHours = String(line.utf16[String.UTF16Index(result.rangeAt(1).location)..<String.UTF16Index(result.rangeAt(1).location + result.rangeAt(1).length)])
          let startMinutes = String(line.utf16[String.UTF16Index(result.rangeAt(2).location)..<String.UTF16Index(result.rangeAt(2).location + result.rangeAt(2).length)])
          let startSeconds = String(line.utf16[String.UTF16Index(result.rangeAt(3).location)..<String.UTF16Index(result.rangeAt(3).location + result.rangeAt(3).length)])
          let startMilliseconds = String(line.utf16[String.UTF16Index(result.rangeAt(4).location)..<String.UTF16Index(result.rangeAt(4).location + result.rangeAt(4).length)])

          let endHours = String(line.utf16[String.UTF16Index(result.rangeAt(5).location)..<String.UTF16Index(result.rangeAt(5).location + result.rangeAt(5).length)])
          let endMinutes = String(line.utf16[String.UTF16Index(result.rangeAt(6).location)..<String.UTF16Index(result.rangeAt(6).location + result.rangeAt(6).length)])
          let endSeconds = String(line.utf16[String.UTF16Index(result.rangeAt(7).location)..<String.UTF16Index(result.rangeAt(7).location + result.rangeAt(7).length)])
          let endMilliseconds = String(line.utf16[String.UTF16Index(result.rangeAt(8).location)..<String.UTF16Index(result.rangeAt(8).location + result.rangeAt(8).length)])

          current = Caption()
          current?.start = TimeInterval(hours: Int(startHours!)!, minutes: Int(startMinutes!)!, seconds: Int(startSeconds!)!, milliseconds: Int(startMilliseconds!)!)
          current?.end = TimeInterval(hours: Int(endHours!)!, minutes: Int(endMinutes!)!, seconds: Int(endSeconds!)!, milliseconds: Int(endMilliseconds!)!)
        }
      }
    }

    // Enumerated text does not enumerate a final empty line upon newline/EOF, misses capturing last
    // caption.
    if current != nil && captions.isEmpty == false && current! != captions.last! {
      captions.append(current!)
    }

    return captions
  }
}

extension Session {
  var localVttUrl: URL {
    let base = Bundle.main.url(forResource: "wwdc-session-transcripts", withExtension: nil)!
    let vtt = base
      .appendingPathComponent(year, isDirectory: true)
      .appendingPathComponent(number)
      .appendingPathExtension("vtt")
    return vtt
  }
}
