import ReactiveSwift

enum DownloadStatus {
  case remote
  case downloading(progress: Float)
  case downloaded(url: URL)
  // TODO: case failed(error: Error), needs design
}

fileprivate extension Session {
  var filename: String {
    return identifier.rawValue + ".mp4"
  }
}

final class DownloadsService: NSObject {

  fileprivate let sessions: [Session]

  // When we implement filtering, we'll need to rework this as
  // `MutableProperty<[Session: MutableProperty<DownloadStatus>]>`
  fileprivate lazy var statuses: [Session: MutableProperty<DownloadStatus>] = {
    return self.existingDownloadsByInspectingFilesystem
  }()

  fileprivate lazy var urlSession: URLSession = {
    return URLSession(
      configuration: self.urlSessionConfig,
      delegate: self,
      delegateQueue: self.urlSessionOpQueue
    )
  }()
  fileprivate lazy var urlSessionConfig: URLSessionConfiguration = {
    let config = URLSessionConfiguration.background(withIdentifier: "io.smike.majorinput.downloads")
    config.allowsCellularAccess = false
    config.isDiscretionary = true
    config.networkServiceType = .background
    config.sessionSendsLaunchEvents = false
    return config
  }()
  fileprivate var urlSessionOpQueue: OperationQueue = {
    let q = OperationQueue()
    q.underlyingQueue = DispatchQueue.main
    return q
  }()

  // synchronize usage on main thread
  fileprivate var downloads = Bimap<Session, URLSessionDownloadTask>()

  fileprivate let fileManager = FileManager.default

  /// Downloads are placed in <sandbox>/Library/Caches/<bundle id>/Downloads, intending to exclude
  /// them from backup.
  fileprivate var downloadsDirectory: URL {
    let caches = self.fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
    let bundleId = Bundle.main.bundleIdentifier!
    let cache = caches.appendingPathComponent(bundleId).appendingPathComponent("Downloads")
    return cache
  }

  init(sessions: [Session]) {
    self.sessions = sessions
    super.init()
    touchDownloadsDirectory()
  }

  func status(for session: Session) -> Property<DownloadStatus> {
    let status = _status(for: session)
    return Property(status)
  }

  func downloadVideo(for session: Session) {
    _status(for: session).value = .downloading(progress: 0)

    let task = urlSession.downloadTask(with: session.downloadSD)
    downloads[key: session] = task
    task.resume()
  }

  func cancelDownload(for session: Session) {
    downloads[key: session]?.cancel()
    downloads.removeValueForKey(session)
    _status(for: session).value = .remote
  }

  func deleteDownload(for session: Session) {
    let url = self.url(for: session)
    do {
      try fileManager.removeItem(at: url)
    } catch {
      print("Could not remove item at \(url)\n\(error)")
      return
    }
    _status(for: session).value = .remote
  }
}

extension DownloadsService: URLSessionDownloadDelegate {
  func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
    guard
      let error = error,
      let task = task as? URLSessionDownloadTask,
      let session = downloads[value: task]
      else { return }
    print("Download for \(session.identifier) failed: \(error)")
    _status(for: session).value = .remote
  }

  func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
    guard let session = downloads[value: downloadTask]
      else { return }
    downloads.removeValueForKey(session)
    do {
      try fileManager.moveItem(at: location, to: url(for: session))
    } catch {
      _status(for: session).value = .remote
      return
    }
    _status(for: session).value = .downloaded(url: url(for: session))
  }

  func urlSession(_ session: URLSession,
                  downloadTask: URLSessionDownloadTask,
                  didWriteData bytesWritten: Int64,
                  totalBytesWritten: Int64,
                  totalBytesExpectedToWrite: Int64) {

    guard let session = downloads[value: downloadTask]
      else { return }
    _status(for: session).value = .downloading(progress: Float(totalBytesWritten)/Float(totalBytesExpectedToWrite))
  }
}

fileprivate extension DownloadsService {
  func touchDownloadsDirectory() {
    try? fileManager.createDirectory(at: self.downloadsDirectory, withIntermediateDirectories: true, attributes: nil)
  }

  var existingDownloadsByInspectingFilesystem: [Session: MutableProperty<DownloadStatus>] {
    do {
      let urls = try fileManager.contentsOfDirectory(at: self.downloadsDirectory, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
      let sessions: [Session] = urls.map { url in
        let filename = url.deletingPathExtension().lastPathComponent
        let components = filename.components(separatedBy: "-")
        let identifier = Session.makeIdentifier(conference: .wwdc, year: components[1], number: components[2])
        let session = self.sessions.first { $0.identifier == identifier }!
        return session
      }
      var statuses: [Session: MutableProperty<DownloadStatus>] = [:]
      for (session, url) in zip(sessions, urls) {
        statuses[session] = MutableProperty(.downloaded(url: url))
      }
      return statuses
    } catch {
      print("Problem scanning Library/Caches for downloads: \(error)")
      return [:]
    }
  }

  func _status(for session: Session) -> MutableProperty<DownloadStatus> {
    let status: MutableProperty<DownloadStatus>
    if let existing = statuses[session] {
      status = existing
    } else {
      status = MutableProperty(.remote)
      statuses[session] = status
    }
    return status
  }

  func url(for session: Session) -> URL {
    return downloadsDirectory.appendingPathComponent(session.filename)
  }
}
