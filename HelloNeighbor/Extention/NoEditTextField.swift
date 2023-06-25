import UIKit

final class NoEditTextField: UITextField {
    
    /* 入力キャレット非表示 */
    override func caretRect(for position: UITextPosition) -> CGRect {
        return .zero
    }
    /* 範囲選択カーソル非表示 */
    override func selectionRects(for range: UITextRange) -> [UITextSelectionRect] {
        return []
    }
    /* コピー・ペースト・選択等のメニュー非表示 */
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return false
    }
}
