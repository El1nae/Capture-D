import SwiftUI

/// 首次引导页 — 2-3 页分步引导
struct OnboardingView: View {
    @Binding var isCompleted: Bool
    @State private var currentPage = 0

    var body: some View {
        TabView(selection: $currentPage) {
            welcomePage.tag(0)
            howToUsePage.tag(1)
            apiKeyPage.tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .ignoresSafeArea()
    }

    /// 第 1 页：欢迎
    private var welcomePage: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()

            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 64))
                .foregroundStyle(AppTheme.Colors.accent)

            Text("Capture:D")
                .font(.system(size: AppTheme.FontSize.largeTitle, weight: .bold))

            Text("你的第二个照片 App")
                .font(.system(size: AppTheme.FontSize.title))
                .foregroundStyle(AppTheme.Colors.secondaryText)

            VStack(spacing: AppTheme.Spacing.sm) {
                Text("收藏截图，AI 自动整理")
                Text("小说、诗词、画风、歌曲")
                Text("一键归档，智能分类")
            }
            .font(.system(size: AppTheme.FontSize.body))
            .foregroundStyle(AppTheme.Colors.tertiaryText)

            Spacer()

            Button("下一步") { withAnimation { currentPage = 1 } }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, AppTheme.Spacing.xl)

            Spacer().frame(height: 60)
        }
    }

    /// 第 2 页：使用方式
    private var howToUsePage: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()

            VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
                stepRow(number: 1, icon: "camera.viewfinder", text: "截屏或看到喜欢的图片")
                stepRow(number: 2, icon: "square.and.arrow.up", text: "点击分享按钮")
                stepRow(number: 3, icon: "app.badge", text: "选择 Capture:D")
                stepRow(number: 4, icon: "tag", text: "选择分类，点确认")
            }
            .padding(.horizontal, AppTheme.Spacing.xl)

            Text("图片会保存在 app 里\n不占用相册空间")
                .font(.system(size: AppTheme.FontSize.caption))
                .foregroundStyle(AppTheme.Colors.tertiaryText)
                .multilineTextAlignment(.center)

            Spacer()

            Button("下一步") { withAnimation { currentPage = 2 } }
                .buttonStyle(PrimaryButtonStyle())
                .padding(.horizontal, AppTheme.Spacing.xl)

            Spacer().frame(height: 60)
        }
    }

    /// 第 3 页：API Key 提示
    private var apiKeyPage: some View {
        VStack(spacing: AppTheme.Spacing.lg) {
            Spacer()

            Image(systemName: "brain")
                .font(.system(size: 48))
                .foregroundStyle(AppTheme.Colors.accent)

            Text("AI 智能分析")
                .font(.system(size: AppTheme.FontSize.title, weight: .medium))

            VStack(spacing: AppTheme.Spacing.sm) {
                Text("配置 API Key 后")
                Text("AI 会自动识别图片出处")
                Text("生成诗词全文、歌词、画风分析等")
            }
            .font(.system(size: AppTheme.FontSize.body))
            .foregroundStyle(AppTheme.Colors.secondaryText)
            .multilineTextAlignment(.center)

            Text("可以稍后在设置中配置")
                .font(.system(size: AppTheme.FontSize.caption))
                .foregroundStyle(AppTheme.Colors.tertiaryText)

            Spacer()

            Button("开始使用") {
                UserDefaults.standard.set(true, forKey: "onboarding_completed")
                isCompleted = true
            }
            .buttonStyle(PrimaryButtonStyle())
            .padding(.horizontal, AppTheme.Spacing.xl)

            Spacer().frame(height: 60)
        }
    }

    private func stepRow(number: Int, icon: String, text: String) -> some View {
        HStack(spacing: AppTheme.Spacing.md) {
            ZStack {
                Circle()
                    .fill(AppTheme.Colors.accent)
                    .frame(width: 32, height: 32)
                Text("\(number)")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.white)
            }
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(AppTheme.Colors.accent)
                .frame(width: 30)
            Text(text)
                .font(.system(size: AppTheme.FontSize.body))
        }
    }
}
