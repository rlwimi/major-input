import SwiftyJSON

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
