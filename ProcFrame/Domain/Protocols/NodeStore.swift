import Foundation

protocol NodeStore: AnyObject {
    var nodes: [ProcNode] { get set }
    var selectedNodeID: UUID? { get set }
    var actionMarks: [ActionMark] { get set }
    var editionType: EditionType { get set }

    func reorderNodesByZPosition()
}
