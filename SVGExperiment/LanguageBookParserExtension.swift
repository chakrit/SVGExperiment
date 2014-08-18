import Foundation

class LanguageBookParserExtension: NSObject, SVGKParserExtension {
    func supportedNamespaces() -> [AnyObject]! { return ["http://languagebook.hyperworks.co.th/"] }
    func supportedTags() -> [AnyObject]! { return nil }
    
    func handleStartElement(name: String!,
        document: SVGKSource!,
        namePrefix prefix: String!,
        namespaceURI XMLNSURI: String!,
        attributes: NSMutableDictionary!,
        parseResult: SVGKParseResult!,
        parentNode: Node!) -> Node! {
        // TODO:
        return nil
    }
    
    func handleEndElement(newNode: Node!, document: SVGKSource!, parseResult: SVGKParseResult!) {
        // TODO:
    }
}
