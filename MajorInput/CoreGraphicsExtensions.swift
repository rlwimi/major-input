import CoreGraphics

extension CGRect {
  var aspectRatio: CGFloat {
    return size.aspectRatio
  }
}

extension CGSize {
  var aspectRatio: CGFloat {
    return width / height
  }
}
