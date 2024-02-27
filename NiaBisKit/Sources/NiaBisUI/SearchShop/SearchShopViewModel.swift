import Combine
import MapKit

final class SearchShopViewModel: NSObject, MKLocalSearchCompleterDelegate, ObservableObject {
  private let completer: MKLocalSearchCompleter
  private var cancellable: Set<AnyCancellable> = []

  @Published var results: [MKLocalSearchCompletion] = []
  @Published var query: String = ""
  
  override init() {
    completer = .init()
    super.init()
    completer.delegate = self
    completer.resultTypes = .pointOfInterest // TODO What to set?
    $query
      .sink { [weak self]  query in
        guard let self else { return }
        completer.queryFragment = query
      }
      .store(in: &cancellable)
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
