import Observation
import Supabase

@Observable
final class AuthController {
  var session: Session?

  @ObservationIgnored
  private var observeAuthStateChangesTask: Task<Void, Never>?

  init() {
    observeAuthStateChangesTask = Task {
      for await (event, session) in await supabase.auth.authStateChanges {
        guard [.initialSession, .signedIn, .signedOut].contains(event) else { return }

        self.session = session
      }
    }
  }

  deinit {
    observeAuthStateChangesTask?.cancel()
  }
}
