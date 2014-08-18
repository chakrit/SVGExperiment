import Foundation

extension NSObject {
    func observe(keyPath: String, usingBlock block: () -> ()) -> BlockObserver {
        let observer = BlockObserver(keyPath: keyPath, block: block)
        addObserver(observer,
            forKeyPath: keyPath,
            options: NSKeyValueObservingOptions(0),
            context: nil)
        
        return observer
    }
}

@objc class BlockObserver: NSObject {
    private let _keyPath: String
    private let _block: () -> ()
    
    init(keyPath: String, block: () -> ()) {
        _keyPath = keyPath
        _block = block
    }
    
    override func observeValueForKeyPath(keyPath: String!,
        ofObject object: AnyObject!,
        change: [NSObject: AnyObject]!,
        context: UnsafeMutablePointer<()>) {
        
        // TODO: Somehow comparing AnyObject throws a lot of weird NSObject errors. So we're
        //   skipping that for now.
        if keyPath == _keyPath { _block() }
    }
}
