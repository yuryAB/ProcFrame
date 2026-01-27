import Foundation

protocol ImageImporting {
    func importImages(completion: @escaping ([ImportedImage]) -> Void)
}
