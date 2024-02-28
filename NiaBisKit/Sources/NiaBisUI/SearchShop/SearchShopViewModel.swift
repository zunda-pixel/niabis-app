import MapKit
import Observation

@Observable
final class SearchShopViewModel: NSObject, MKLocalSearchCompleterDelegate {
  private let completer: MKLocalSearchCompleter

  var results: [MKLocalSearchCompletion] = []
  var query: String = "" {
    didSet {
      completer.queryFragment = query
    }
  }
  
  override init() {
    completer = .init()
    super.init()
    completer.delegate = self
    completer.resultTypes = .pointOfInterest // TODO What to set?
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
