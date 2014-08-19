import Foundation

// TODO: AudioInterval cannot be used in @objc protocols. We need some way to allow passing it via
//   delegates.
typealias AudioTime = NSTimeInterval
typealias AudioInterval = ClosedInterval<AudioTime>

class AudioBase: NSObject { }
