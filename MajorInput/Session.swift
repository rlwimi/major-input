import Foundation

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

  // pre-2015 tracks
  case appServices = "App Services"
  case coreOS = "Core OS"
  case essentials = "Essentials"
  case general = "General"
  case graphicsMediaAndGames = "Graphics, Media & Games"
  case safariAndWeb = "Safari & Web"
  case frameworks = "Frameworks"
  case services = "Services"
  case specialEvents = "Special Events"
  case tools = "Tools"
}

enum Conference: String {
  case wwdc = "WWDC"
}

struct Session: Identifiable {
  let identifier: Identifier<Session>
  let conference: Conference
  let description: String
  let downloadHD: URL
  let downloadSD: URL
  let duration: Int?
  let focuses: [Focus]
  let image: URL?
  let number: String
  let title: String
  let track: Track
  let year: String

  var durationText: String? {
    guard let duration = duration
      else { return nil }
    return TimeInterval(duration).digitalClockText
  }

  var webVttUrl: URL {
    var url = downloadSD.deletingQuery
    url.deletePathExtension()
    let basename = url.lastPathComponent
    url.deleteLastPathComponent()
    url.appendPathComponent("subtitles/eng/\(basename).vtt")
    return url
  }

  init(
    conference: Conference,
    description: String,
    downloadHD: URL,
    downloadSD: URL,
    duration: Int?,
    focuses: [Focus],
    image: URL?,
    number: String,
    title: String,
    track: Track,
    year: String) {

    self.identifier = Session.makeIdentifier(conference: conference, year: year, number: number)
    self.conference = conference
    self.description = description
    self.downloadHD = downloadHD
    self.downloadSD = downloadSD
    self.duration = duration
    self.focuses = focuses
    self.image = image
    self.number = number
    self.title = title
    self.track = track
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
      lhs.downloadHD == rhs.downloadHD &&
      lhs.downloadSD == rhs.downloadSD &&
      lhs.duration == rhs.duration &&
      lhs.focuses == rhs.focuses &&
      lhs.image == rhs.image &&
      lhs.title == rhs.title &&
      lhs.track == rhs.track
  }
}

extension Session: Hashable {
  var hashValue: Int {
    return identifier.hashValue
  }
}
