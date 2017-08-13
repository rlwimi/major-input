import Foundation
import Regex
import SwiftyJSON

final class SessionsService {

  let fileManager = FileManager.default

  let byConference: SortDescriptor<Session> = sortDescriptor(property: { $0.conference.rawValue })
  let byYearDescending: SortDescriptor<Session> = sortDescriptor(property: { $0.year }, ascending: false)
  let byNumber: SortDescriptor<Session> = sortDescriptor(property: { $0.number })

  var defaultSortDescriptors: SortDescriptor<Session> {
    return combine(sortDescriptors: [byConference, byYearDescending, byNumber])
  }

  lazy var sessions: [Session] = {
    let url = Bundle.main.url(forResource: "sessions.json", withExtension: nil)!
    let data = try! Data(contentsOf: url)
    let json = JSON(data: data)
    let sessions = json.arrayValue
      .flatMap(Session.init(json:))
      .sorted(by: self.defaultSortDescriptors)

    return sessions
  }()

  func canProvideCaptions(for session: Session) -> Bool {
    let url = session.localVttUrl
    let canProvide = fileManager.fileExists(atPath: url.path)
    return canProvide
  }

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

    let regex = Regex("^(\\d\\d):(\\d\\d):(\\d\\d)[,.](\\d\\d\\d) --> (\\d\\d):(\\d\\d):(\\d\\d)[,.](\\d\\d\\d).*$")

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
        if
          let match = regex.firstMatch(in: line),
          match.captures.count == 8,
          let startHours = match.captures[0],
          let startMinutes = match.captures[1],
          let startSeconds = match.captures[2],
          let startMilliseconds = match.captures[3],
          let endHours = match.captures[4],
          let endMinutes = match.captures[5],
          let endSeconds = match.captures[6],
          let endMilliseconds = match.captures[7]
        {
          current = Caption()
          current?.start = TimeInterval(hours: Int(startHours)!, minutes: Int(startMinutes)!, seconds: Int(startSeconds)!, milliseconds: Int(startMilliseconds)!)
          current?.end = TimeInterval(hours: Int(endHours)!, minutes: Int(endMinutes)!, seconds: Int(endSeconds)!, milliseconds: Int(endMilliseconds)!)
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
    let url = base
      .appendingPathComponent(year, isDirectory: true)
      .appendingPathComponent(number)
      .appendingPathExtension("vtt")
    return url
  }
}
