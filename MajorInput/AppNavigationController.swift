import UIKit

final class AppNavigationController: UINavigationController {

  let builder: AppBuilder
  let shelf: ShelfViewController

  init(builder: AppBuilder) {
    self.builder = builder
    shelf = builder.makeShelfViewController()
    super.init(nibName: nil, bundle: nil)
    configureAppearance()
    setViewControllers([shelf], animated: false)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)

    shelf.onSelectSession = strongify(weak: self) { `self`, session in
      self.shelfDidSelect(session)
    }
  }
}

fileprivate extension AppNavigationController {
  func configureAppearance() {
    let container = UINavigationBar.appearance(whenContainedInInstancesOf: [type(of: self)])
    container.barTintColor = .systemTintColor
    container.titleTextAttributes = [
      NSAttributedStringKey.foregroundColor: UIColor.white,
      NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 24)
    ]
  }

  func shelfDidSelect(_ session: Session) {
    let majorInput = builder.makeMajorInputViewController(session: session)
    majorInput.navigationItem.leftBarButtonItem = makeDoneBarButtonItem()

    majorInput.downcastView.player.showsOverlay
      .producer
      .take(during: majorInput.reactive.lifetime)
      .startWithValues(strongify(weak: self) { `self`, showsOverlay in
        self.setNeedsStatusBarAppearanceUpdate()
        self.setNavigationBarHidden(!showsOverlay, animated: true)
      })
    pushViewController(majorInput, animated: true)
  }

  func makeDoneBarButtonItem() -> UIBarButtonItem {
    let bbi = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
    bbi.tintColor = .white
    return bbi
  }

  @objc func done() {
    popViewController(animated: true)
  }
}
