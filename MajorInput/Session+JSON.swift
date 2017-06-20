import SwiftyJSON

extension Session {
  init?(json: JSON) {
    guard
      let yearValue = json["year"].int,
      yearValue > 2012, // 2012 videos are missing subtitles, earlier years are not available and/or missing subtitles
      let year = json["year"].int.flatMap(String.init(describing:)),
      let description = json["description"].string,
      let downloadSD = json["download_sd"].url,
      let downloadHD = json["download_hd"].url,
      let focuses = json["focus"].array?.flatMap({ $0.string }).flatMap(Focus.init(rawValue:)),
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
    self.downloadSD = downloadSD
    self.downloadHD = downloadHD
    self.duration = json["duration"].int
    self.focuses = focuses
    self.image = json["image"].url
    self.number = number
    self.title = title
    self.track = track
    self.year = year
  }

  var dictionary: [String: Any] {
    var d: [String: Any] = [:]
    d["description"] = description
    d["download_hd"] = downloadHD.absoluteString
    d["download_sd"] = downloadSD.absoluteString
    d["duration"] = duration ?? nil
    d["focus"] = focuses.map({ $0.rawValue })
    d["image"] = image?.absoluteString
    d["id"] = number
    d["track"] = track.rawValue
    d["title"] = title
    d["year"] = Int(year) ?? nil
    return d
  }
}
