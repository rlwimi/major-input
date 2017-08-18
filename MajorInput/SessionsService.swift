import Foundation
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
    return nil != CaptionsLoader(forSession: session.number, from: session.year)
  }

  func captions(for session: Session) -> [Caption] {
    guard let loader = CaptionsLoader(forSession: session.number, from: session.year) else {
      return []
    }
    return loader.captions.sentencifying
  }
}

