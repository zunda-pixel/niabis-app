import Supabase
import SwiftUI

struct SessionKey: EnvironmentKey {
  static let defaultValue: Auth.Session = .empty
}

extension Auth.Session {
  static let empty: Self = .init(
    accessToken: "",
    tokenType: "",
    expiresIn: .zero,
    expiresAt: .zero,
    refreshToken: "",
    user: .init(
      id: .init(),
      appMetadata: [:],
      userMetadata: [:],
      aud: "",
      createdAt: .now,
      updatedAt: .now
    )
  )
}

extension EnvironmentValues {
  var session: Auth.Session {
    get { self[SessionKey.self] }
    set { self[SessionKey.self] = newValue }
  }
}
