import UIKit
import UniformTypeIdentifiers

/// Share Extension 入口 — 接收图片，在分享面板内显示分类选择
class ShareViewController: UIViewController {
    private var imageData: Data?
    private var selectedCategories: Set<String> = []
    private let storageURL: URL = {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.yourname.captured")!
            .appendingPathComponent("Pending", isDirectory: true)
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        extractImage()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        let titleLabel = UILabel()
        titleLabel.text = "保存到 Capture:D"
        titleLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        titleLabel.textAlignment = .center

        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8

        let categories = ["小说", "诗词", "画风", "歌曲"]
        for name in categories {
            let button = UIButton(type: .system)
            button.setTitle(name, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
            button.layer.cornerRadius = 12
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.systemBlue.cgColor
            button.backgroundColor = .secondarySystemBackground
            button.setTitleColor(.label, for: .normal)
            button.addAction(UIAction { [weak self] _ in
                self?.toggleCategory(name, button: button)
            }, for: .touchUpInside)
            button.heightAnchor.constraint(equalToConstant: 44).isActive = true
            stackView.addArrangedSubview(button)
        }

        let confirmButton = UIButton(type: .system)
        confirmButton.setTitle("确认", for: .normal)
        confirmButton.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        confirmButton.backgroundColor = .systemBlue
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.layer.cornerRadius = 12
        confirmButton.addAction(UIAction { [weak self] _ in
            self?.confirm()
        }, for: .touchUpInside)
        confirmButton.heightAnchor.constraint(equalToConstant: 48).isActive = true

        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.addAction(UIAction { [weak self] _ in
            self?.cancel()
        }, for: .touchUpInside)

        let container = UIStackView(arrangedSubviews: [titleLabel, stackView, confirmButton, cancelButton])
        container.axis = .vertical
        container.spacing = 16
        container.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(container)

        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            container.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            container.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func toggleCategory(_ name: String, button: UIButton) {
        if selectedCategories.contains(name) {
            selectedCategories.remove(name)
            button.backgroundColor = .secondarySystemBackground
            button.setTitleColor(.label, for: .normal)
        } else {
            selectedCategories.insert(name)
            button.backgroundColor = .systemBlue
            button.setTitleColor(.white, for: .normal)
        }
    }

    private func extractImage() {
        guard let items = extensionContext?.inputItems as? [NSExtensionItem] else { return }

        for item in items {
            guard let attachments = item.attachments else { continue }
            for provider in attachments {
                if provider.hasItemConformingToTypeIdentifier(UTType.image.identifier) {
                    provider.loadItem(forTypeIdentifier: UTType.image.identifier) { [weak self] data, _ in
                        DispatchQueue.main.async {
                            if let url = data as? URL, let imgData = try? Data(contentsOf: url) {
                                self?.imageData = imgData
                            } else if let imgData = data as? Data {
                                self?.imageData = imgData
                            } else if let image = data as? UIImage {
                                self?.imageData = image.jpegData(compressionQuality: 0.9)
                            }
                        }
                    }
                    return
                }
            }
        }
    }

    private func confirm() {
        guard let imageData = imageData, !selectedCategories.isEmpty else {
            cancel()
            return
        }

        // 确保目录存在
        try? FileManager.default.createDirectory(at: storageURL, withIntermediateDirectories: true)

        // 保存图片文件
        let fileName = UUID().uuidString + ".jpg"
        let fileURL = storageURL.appendingPathComponent(fileName)
        try? imageData.write(to: fileURL)

        // 追加到 metadata
        let metadataURL = storageURL.appendingPathComponent("metadata.json")
        var items: [PendingImageDTO] = []
        if let existingData = try? Data(contentsOf: metadataURL),
           let existing = try? JSONDecoder().decode([PendingImageDTO].self, from: existingData) {
            items = existing
        }
        items.append(PendingImageDTO(
            imageFileName: fileName,
            categories: Array(selectedCategories),
            savedAt: Date()
        ))
        if let jsonData = try? JSONEncoder().encode(items) {
            try? jsonData.write(to: metadataURL)
        }

        extensionContext?.completeRequest(returningItems: nil)
    }

    private func cancel() {
        extensionContext?.cancelRequest(withError: NSError(domain: "com.captured", code: 0))
    }
}

/// Share Extension 内部用的临时数据结构（和主 App 的 PendingImage 对应）
struct PendingImageDTO: Codable {
    let imageFileName: String
    let categories: [String]
    let savedAt: Date
}
