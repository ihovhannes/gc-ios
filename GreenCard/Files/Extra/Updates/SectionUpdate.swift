import Foundation

struct SectionUpdates {

  let delete: IndexSet
  let insert: IndexSet

  static var empty: SectionUpdates {
    return SectionUpdates(delete: IndexSet(), insert: IndexSet())
  }

  var empty: Bool {
    return delete.count == 0 && insert.count == 0
  }
}
