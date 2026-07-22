import UIKit
import UniformTypeIdentifiers

/// Share Extension 入口 — 接收图片，分类选择 + tag + 命名输入
class ShareViewController: UIViewController {
    private var imageData: Data?
    private var selectedCategories: Set<String> = []
    private let storageURL: URL = {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.el1nA.CaptureD")!
            .appendingPathComponent("Pending", isDirectory: true)
    }()

    private let accentColor = UIColor(red: 0.49, green: 0.569, blue: 0.447, alpha: 1)
    private let tertiaryTextColor = UIColor(red: 0.722, green: 0.718, blue: 0.69, alpha: 1)

    private var nameField: UITextField!
    private var tagField: UITextField!
    private var tagLabelsStack: UIStackView!
    private var tags: [String] = []

    private func serifFont(ofSize size: CGFloat, weight: UIFont.Weight = .regular) -> UIFont {
        let base = UIFont.systemFont(ofSize: size, weight: weight)
        if let descriptor = base.fontDescriptor.withDesign(.rounded) {
            return UIFont(descriptor: descriptor, size: size)
        }
        return base
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        extractImage()
    }

    private func setupUI() {
        view.backgroundColor = .systemBackground

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let container = UIStackView()
        container.axis = .vertical
        container.spacing = 12
        container.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(container)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            container.topAnchor.constraint(equalTo: scrollView.topAnchor, constant: 20),
            container.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor, constant: 20),
            container.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor, constant: -20),
            container.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: -20),
            container.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: -40)
        ])

        // 标题
        let titleLabel = UILabel()
        titleLabel.text = "保存到 Capture:D"
        titleLabel.font = serifFont(ofSize: 17, weight: .regular)
        titleLabel.textAlignment = .center
        container.addArrangedSubview(titleLabel)

        // 分类按钮
        let categoryLabel = makeLabel("选择分类（必选）")
        container.addArrangedSubview(categoryLabel)

        let categoryStack = UIStackView()
        categoryStack.axis = .horizontal
        categoryStack.distribution = .fillEqually
        categoryStack.spacing = 8

        let categories = ["找书", "找诗", "找画", "找歌"]
        for name in categories {
            let button = UIButton(type: .system)
            button.setTitle(name, for: .normal)
            button.titleLabel?.font = serifFont(ofSize: 15, weight: .regular)
            button.layer.cornerRadius = 22
            button.layer.borderWidth = 1
            button.layer.borderColor = accentColor.cgColor
            button.backgroundColor = .clear
            button.setTitleColor(accentColor, for: .normal)
            button.addAction(UIAction { [weak self] _ in
                self?.toggleCategory(name, button: button)
            }, for: .touchUpInside)
            button.heightAnchor.constraint(equalToConstant: 44).isActive = true
            categoryStack.addArrangedSubview(button)
        }
        container.addArrangedSubview(categoryStack)

        // 命名框
        let nameLabel = makeLabel("命名（可选，格式：作品名|作者）")
        container.addArrangedSubview(nameLabel)

        nameField = makeTextField(placeholder: "例：静夜思|李白")
        container.addArrangedSubview(nameField)

        // 标签框
        let tagLabel = makeLabel("标签（可选，回车添加）")
        container.addArrangedSubview(tagLabel)

        tagField = makeTextField(placeholder: "添加标签")
        tagField.returnKeyType = .done
        tagField.addAction(UIAction { [weak self] _ in
            self?.addTag()
        }, for: .editingDidEndOnExit)
        container.addArrangedSubview(tagField)

        tagLabelsStack = UIStackView()
        tagLabelsStack.axis = .horizontal
        tagLabelsStack.spacing = 6
        tagLabelsStack.distribution = .fill
        container.addArrangedSubview(tagLabelsStack)

        // 确认/取消
        let confirmButton = UIButton(type: .system)
        confirmButton.setTitle("确认", for: .normal)
        confirmButton.titleLabel?.font = serifFont(ofSize: 17, weight: .regular)
        confirmButton.backgroundColor = accentColor
        confirmButton.setTitleColor(.white, for: .normal)
        confirmButton.layer.cornerRadius = 24
        confirmButton.addAction(UIAction { [weak self] _ in
            self?.confirm()
        }, for: .touchUpInside)
        confirmButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        container.addArrangedSubview(confirmButton)

        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.titleLabel?.font = serifFont(ofSize: 15, weight: .regular)
        cancelButton.setTitleColor(tertiaryTextColor, for: .normal)
        cancelButton.addAction(UIAction { [weak self] _ in
            self?.cancel()
        }, for: .touchUpInside)
        container.addArrangedSubview(cancelButton)
    }

    private func makeLabel(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.font = serifFont(ofSize: 12, weight: .light)
        label.textColor = tertiaryTextColor
        return label
    }

    private func makeTextField(placeholder: String) -> UITextField {
        let field = UITextField()
        field.placeholder = placeholder
        field.font = serifFont(ofSize: 15, weight: .light)
        field.borderStyle = .roundedRect
        field.heightAnchor.constraint(equalToConstant: 40).isActive = true
        return field
    }

    private func toggleCategory(_ name: String, button: UIButton) {
        if selectedCategories.contains(name) {
            selectedCategories.remove(name)
            button.backgroundColor = .clear
            button.setTitleColor(accentColor, for: .normal)
        } else {
            selectedCategories.insert(name)
            button.backgroundColor = accentColor
            button.setTitleColor(.white, for: .normal)
        }
    }

    private func addTag() {
        guard let text = tagField.text?.trimmingCharacters(in: .whitespaces),
              !text.isEmpty, !tags.contains(text) else { return }
        tags.append(text)
        tagField.text = ""
        refreshTagLabels()
    }

    private func refreshTagLabels() {
        tagLabelsStack.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for tag in tags {
            let chip = UILabel()
            chip.text = "  \(tag)  "
            chip.font = serifFont(ofSize: 12, weight: .light)
            chip.textColor = accentColor
            chip.layer.cornerRadius = 12
            chip.layer.borderWidth = 0.5
            chip.layer.borderColor = accentColor.cgColor
            chip.clipsToBounds = true
            chip.textAlignment = .center
            tagLabelsStack.addArrangedSubview(chip)
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

        try? FileManager.default.createDirectory(at: storageURL, withIntermediateDirectories: true)

        let fileName = UUID().uuidString + ".jpg"
        let fileURL = storageURL.appendingPathComponent(fileName)
        try? imageData.write(to: fileURL)

        let metadataURL = storageURL.appendingPathComponent("metadata.json")
        var items: [PendingImageDTO] = []
        if let existingData = try? Data(contentsOf: metadataURL),
           let existing = try? JSONDecoder().decode([PendingImageDTO].self, from: existingData) {
            items = existing
        }
        items.append(PendingImageDTO(
            imageFileName: fileName,
            categories: Array(selectedCategories),
            savedAt: Date(),
            name: nameField.text?.trimmingCharacters(in: .whitespaces) ?? "",
            tags: tags
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

struct PendingImageDTO: Codable {
    let imageFileName: String
    let categories: [String]
    let savedAt: Date
    let name: String
    let tags: [String]
}
