import Foundation

struct RowUpdates {

  let delete: [IndexPath]
  let insert: [IndexPath]
  let reload: [IndexPath]

  static var empty: RowUpdates {
    return RowUpdates(delete: [], insert: [], reload: [])
  }

  var empty: Bool {
    return delete.count == 0 && insert.count == 0 && reload.count == 0
  }
}
