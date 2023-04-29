import Foundation

struct CollectionWidthParameters {
    let cellsNumber: Int
    let leftInset: CGFloat
    let rightInset: CGFloat
    let interCellSpacing: CGFloat
    let widthInsets: CGFloat
    
    init(cellsNumber: Int, leftInset: CGFloat, rightInset: CGFloat, interCellSpacing: CGFloat) {
        self.cellsNumber = cellsNumber
        self.leftInset = leftInset
        self.rightInset = rightInset
        self.interCellSpacing = interCellSpacing
        self.widthInsets = interCellSpacing * CGFloat(cellsNumber - 1) + leftInset + rightInset
    }
}
