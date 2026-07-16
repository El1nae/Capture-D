import SwiftUI

/// 根视图 — 引导页完成前显示引导，完成后显示主界面
struct ContentView: View {
    @State private var onboardingCompleted = UserDefaults.standard.bool(forKey: "onboarding_completed")

    var body: some View {
        if onboardingCompleted {
            CollectionView()
        } else {
            OnboardingView(isCompleted: $onboardingCompleted)
        }
    }
}
