//
//  RichTextViewController.swift
//  PiCam
//
//  Created by Tyson Miles on 2/6/2025.
//
import UIKit

class RichTextViewController: UIViewController {
    
    // MARK: - UI Elements
    private let textView: UITextView = {
        let tv = UITextView()
        tv.isEditable = false
        tv.isSelectable = true
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.backgroundColor = .systemBackground
        tv.textContainerInset = UIEdgeInsets(top: 20, left: 16, bottom: 20, right: 16)
        return tv
    }()
    
    private let activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView(style: .large)
        ai.translatesAutoresizingMaskIntoConstraints = false
        ai.hidesWhenStopped = true
        return ai
    }()
    
    // MARK: - Properties
    var documentName: String!
    var displayTitle: String!
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        loadDocumentContent()
    }
    
    // MARK: - Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = displayTitle
        
        view.addSubview(textView)
        view.addSubview(activityIndicator)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Document Loading
    private func loadDocumentContent() {
        activityIndicator.startAnimating()
        
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self, let documentName = self.documentName else { return }
            
            let result = self.loadDocumentFile(named: documentName)
            
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                
                switch result {
                case .success(let attributedString):
                    self.textView.attributedText = attributedString
                case .failure(let error):
                    self.showErrorAlert(message: error.localizedDescription)
                }
            }
        }
    }
    
    private func loadDocumentFile(named filename: String) -> Result<NSAttributedString, Error> {
        // Extract filename and extension
        let components = filename.split(separator: ".")
        guard components.count >= 2 else {
            return .failure(NSError(domain: "InvalidFilename", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid filename format"]))
        }
        
        let name = String(components[0])
        let ext = String(components[1])
        
        // Handle folder paths
        if filename.contains("/") {
            let pathComponents = filename.split(separator: "/")
            let folderPath = pathComponents.dropLast().joined(separator: "/")
            
            guard let url = Bundle.main.url(
                forResource: name,
                withExtension: ext,
                subdirectory: folderPath
            ) else {
                return .failure(NSError(domain: "FileNotFound", code: 404, userInfo: [NSLocalizedDescriptionKey: "Document not found in folder"]))
            }
            
            return loadRTFFromURL(url)
        }
        
        // Handle root files
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else {
            return .failure(NSError(domain: "FileNotFound", code: 404, userInfo: [NSLocalizedDescriptionKey: "Document file not found"]))
        }
        
        return loadRTFFromURL(url)
    }
    
    private func loadRTFFromURL(_ url: URL) -> Result<NSAttributedString, Error> {
        do {
            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
                .documentType: NSAttributedString.DocumentType.rtf
            ]
            
            let data = try Data(contentsOf: url)
            let attributedString = try NSAttributedString(data: data, options: options, documentAttributes: nil)
            return .success(attributedString)
        } catch {
            return .failure(error)
        }
    }
    // MARK: - Error Handling
    private func showErrorAlert(message: String) {
        let alert = MidAlertView(
            type: .alert,
            title: "Unable to Load",
            message: "An error occured while loading the document you requested. The error was: \(message). Please try again.",
            symbol: UIImage(systemName: "exclamationmark.circle.fill"),
            primaryAction: { print("insert action") },
            primaryActionName: "OK",
            primaryActionColor: .systemBlue
        )
        
        alert.show(in: self.view)
    }
}
