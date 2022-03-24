import Foundation

struct Updates {

  let row: RowUpdates
  let section: SectionUpdates

  static var empty: Updates {
    return Updates(row: RowUpdates.empty, section: SectionUpdates.empty)
  }

  var empty: Bool {
    return row.empty && section.empty
  }
}
