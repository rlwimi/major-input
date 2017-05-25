import SwiftyJSON

enum Focus: String {
  case iOS
  case macOS
  case tvOS
  case watchOS
}

enum Track: String {
  case appFrameworks = "App Frameworks"
  case systemFrameworks = "System Frameworks"
  case developerTools = "Developer Tools"
  case featured = "Featured"
  case graphicsAndGames = "Graphics and Games"
  case design = "Design"
  case media = "Media"
  case distribution = "Distribution"
}

enum Conference: String {
  case wwdc = "WWDC"
}

struct Session: Identifiable {
  let identifier: Identifier<Session>
  let conference: Conference
  let description: String
  let download: URL
  let duration: Int?
  let focuses: [Focus]
  let image: URL
  let number: String
  let title: String
  let track: Track
  let vtt: URL?
  let year: String

  var durationText: String? {
    guard let duration = duration
      else { return nil }
    return TimeInterval(duration).digitalClockText
  }

  init(
    conference: Conference,
    description: String,
    download: URL,
    duration: Int?,
    focuses: [Focus],
    image: URL,
    number: String,
    title: String,
    track: Track,
    vtt: URL?,
    year: String) {

    self.identifier = Session.makeIdentifier(conference: conference, year: year, number: number)
    self.conference = conference
    self.description = description
    self.download = download
    self.duration = duration
    self.focuses = focuses
    self.image = image
    self.number = number
    self.title = title
    self.track = track
    self.vtt = vtt
    self.year = year
  }
}

extension Session {
  init?(json: JSON) {
    guard
      let yearValue = json["year"].int,
      yearValue > 2012, // 2012 videos are missing subtitles, earlier years are not available and/or missing subtitles
      let year = json["year"].int.flatMap(String.init(describing:)),
      let description = json["description"].string,
      let download = json["download_sd"].url,
      let focuses = json["focus"].array?.flatMap({ $0.string }).flatMap(Focus.init(rawValue:)),
      let image = json["images"]["shelf"].url,
      let number = json["id"].string,
      let title = json["title"].string,
      let trackString = json["track"].string,
      let track = Track(rawValue: trackString)
      else {
        return nil
    }
    self.identifier = Session.makeIdentifier(conference: .wwdc, year: year, number: number)
    self.conference = .wwdc
    self.description = description
    self.download = download
    self.duration = json["duration"].int
    self.focuses = focuses
    self.image = image
    self.number = number
    self.title = title
    self.track = track
    self.vtt = json["subtitles"].url
    self.year = year
  }
}

extension Session {
  static func makeIdentifier(conference: Conference, year: String, number: String) -> Identifier<Session> {
    return Identifier(rawValue: [conference.rawValue, year, number].joined(separator: "-"))
  }
}

extension Session: Equatable {

  static func == (lhs: Session, rhs: Session) -> Bool {
    return lhs.year == rhs.year &&
      lhs.number == rhs.number &&
      lhs.description == rhs.description &&
      lhs.download == rhs.download &&
      lhs.duration == rhs.duration &&
      lhs.focuses == rhs.focuses &&
      lhs.image == rhs.image &&
      lhs.title == rhs.title &&
      lhs.track == rhs.track &&
      lhs.vtt == rhs.vtt
  }
}

extension Session: Hashable {
  var hashValue: Int {
    return identifier.hashValue
  }
}
