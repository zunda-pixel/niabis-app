import Contacts
import MapKit
import NiaBisData
import Observation

struct SearchLocationItem: Hashable {
  var completion: MKLocalSearchCompletion
  var location: Location
}

extension SearchLocationView {
  @Observable
  final class ViewState: NSObject, MKLocalSearchCompleterDelegate {
    private let completer: MKLocalSearchCompleter

    var selectedItem: IdentifiedItem<SearchLocationItem>?
    var results: [MKLocalSearchCompletion] = []
    var query: String = "" {
      didSet {
        completer.queryFragment = query
        if query.isEmpty {
          results = []
        }
      }
    }

    override init() {
      completer = .init()
      super.init()
      completer.delegate = self
      completer.resultTypes = .pointOfInterest  // TODO What to set?
    }

    /// MKLocalSearchCompleterDelegate
    /// - Parameter completer: MKLocalSearchCompleter
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
      results = completer.results
    }

    /// MKLocalSearchCompleterDelegate
    /// - Parameters:
    ///   - completer: MKLocalSearchCompleter
    ///   - error: any Error
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
      print(error)
    }
  }
}
