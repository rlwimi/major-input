import UIKit

struct AppDependencies: HasSessionsService, HasDownloadsService {
  let sessionsService: SessionsService
  let downloadsService: DownloadsService
}

final class AppBuilder {

  let dependencies: AppDependencies

  init() {
    let sessionsService = SessionsService()
    let downloadsService = DownloadsService(sessions: sessionsService.sessions)
    dependencies = AppDependencies(sessionsService: sessionsService, downloadsService: downloadsService)
  }

  func makeAppNavigationController() -> AppNavigationController {
    return AppNavigationController(builder: self)
  }

  func makeShelfViewController() -> ShelfViewController {
    return ShelfViewController(dependencies: dependencies)
  }

  func makeMajorInputViewController(session: Session) -> MajorInputViewController {
    return MajorInputViewController(session: session, dependencies: dependencies)
  }
}
