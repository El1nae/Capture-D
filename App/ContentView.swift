import SwiftUI

/// 根视图 — 引导页完成前显示引导，完成后显示主界面
struct ContentView: View {
    @State private var onboardingCompleted = UserDefaults.standard.bool(forKey: "onboarding_completed")
    @State private var showCompose = false
    @Environment(DatabaseManager.self) private var database

    var body: some View {
        if onboardingCompleted {
            ZStack(alignment: .bottomTrailing) {
                CollectionView()

                FABButton(showCompose: $showCompose)
                    .padding(.trailing, 20)
                    .padding(.bottom, 30)
            }
            .sheet(isPresented: $showCompose) {
                ComposeSheet(
                    placeholder: "记录此刻的想法...",
                    navTitle: "碎碎念"
                ) { text in
                    _ = database.createMurmur(text: text)
                }
            }
        } else {
            OnboardingView(isCompleted: $onboardingCompleted)
        }
    }
}
