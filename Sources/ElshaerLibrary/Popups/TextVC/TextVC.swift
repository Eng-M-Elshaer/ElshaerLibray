//
//  TextVC.swift
//  ElshaerLibrary
//
//  Created by Restart iOS Technology on 08/12/2025.
//

import Foundation
#if canImport(UIKit)
import UIKit

// MARK: - TextVC
@MainActor
public final class TextVC: UIViewController {
    
    //MARK: - Properties
    private let htmlString: String
    private let textColor: UIColor?
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let label = UILabel()
    
    //MARK: - Init
    public init(htmlString: String, textColor: UIColor? = .black) {
        self.htmlString = htmlString
        self.textColor = textColor
        super.init(nibName: nil, bundle: nil)
    }
    @available(*, unavailable, message: "Use init(htmlString:textColor:) instead.")
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - LifeCycle
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureUI()
    }

    //MARK: - Private Methods
    private func configureUI() {
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false

        label.numberOfLines = 0
        label.textAlignment = .center
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        label.setContentHuggingPriority(.required, for: .vertical)

        if let attributed = htmlString.htmlToAttributedString {
            if let textColor {
                let mutable = NSMutableAttributedString(attributedString: attributed)
                mutable.addAttribute(.foregroundColor, value: textColor, range: NSRange(location: 0, length: mutable.length))
                label.attributedText = mutable
            } else {
                label.attributedText = attributed
            }
        } else {
            label.text = htmlString
            if let textColor {
                label.textColor = textColor
            }
        }

        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(label)

        let guide = view.layoutMarginsGuide
        NSLayoutConstraint.activate([
            // Scroll view fills the screen within margins
            scrollView.topAnchor.constraint(equalTo: guide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: guide.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),

            // Content view defines scrollable content size
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            // Label pinned to content view
            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 20),
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 16)
        ])
    }
}
#endif
