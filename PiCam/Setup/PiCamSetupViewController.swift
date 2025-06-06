//
//  ViewController 2.swift
//  PiCam
//
//  Created by Tyson Miles on 30/3/2025.
//
import UIKit
import AVFoundation
import Network
import FirebaseFirestore
import FirebaseAuth
import NetworkExtension

class PiCamSetupViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UITextFieldDelegate {
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    let hotspotManager = HotspotManager()
    private let spinner = UIActivityIndicatorView(style: .medium)
    var piConnection: NWConnection?
    let piAddress = "192.168.4.1"
    let piPort: Network.NWEndpoint.Port = 4545
    var ssidInfo: [String]?
    var deviceName: String?
    var serialNumber: String?
    var deviceDocNum: String?
    private let viewfinder = ViewfinderView()
    
    
    @IBOutlet weak var customSerialView: CustomViewView!
    @IBOutlet weak var customQRView: CustomViewViewQR!
    @IBOutlet weak var QRCodeScannerView: UIView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraintQR: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraintFound: NSLayoutConstraint!
    @IBOutlet weak var SerialNumberTextInput: CustomTextField!
    @IBOutlet weak var DeviceModelLabel: UILabel!
    @IBOutlet weak var DeviceModelImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.SerialNumberTextInput.delegate = self
        hideCustomView()
        hideCustomViewQR()
        hideCustomViewFound()
        setupViewfinder()
    }
    
    private func setupViewfinder() {
        viewfinder.translatesAutoresizingMaskIntoConstraints = false
        viewfinder.backgroundColor = .clear
        QRCodeScannerView.addSubview(viewfinder)
        
        NSLayoutConstraint.activate([
            viewfinder.centerXAnchor.constraint(equalTo: QRCodeScannerView.centerXAnchor),
            viewfinder.centerYAnchor.constraint(equalTo: QRCodeScannerView.centerYAnchor),
            viewfinder.widthAnchor.constraint(equalTo: QRCodeScannerView.widthAnchor, multiplier: 0.8),
            viewfinder.heightAnchor.constraint(equalTo: viewfinder.widthAnchor)
        ])
    }
    
    private func hideCustomView() {
        bottomConstraint.constant = -600
        view.layoutIfNeeded()
    }
    private func hideCustomViewQR() {
        bottomConstraintQR.constant = -600
        view.layoutIfNeeded()
    }
    private func hideCustomViewFound() {
        bottomConstraintFound.constant = -600
        view.layoutIfNeeded()
    }
    
    // MARK: - Button Actions
    @IBAction func QRcontinueButtonTapped(_ sender: UIButton) {
        checkCameraPermissions()
        slideUpQR()
    }
    
    @IBAction func SNcontinueButtonTapped(_ sender: UIButton) {
        slideUp()
        subscribeToKeyboardNotifications()
    }
    
    @IBAction func SNcancelButtonTapped(_ sender: UIButton) {
        slideDown()
    }
    @IBAction func QRcancelButtonTapped(_ sender: UIButton) {
        slideDownQR()
        stopCaptureSession()
    }
    
    @IBAction func SNdoneButtonTapped(_ sender: UIButton) {
        let serialnumberinput = SerialNumberTextInput.text ?? "nil"
        if serialnumberinput.contains("LW") || serialnumberinput.contains("CE") && serialnumberinput.count == 9 || serialnumberinput.count == 12 {
            dismissKeyboard()
            slideDown()
            let alert = MidAlertView(
                type: .loadingcustom,
                title: "Just a Moment",  // Ignored
                message: "",  // Ignored
                symbol: UIImage(named: "loadingspinner")
            )
            alert.show(in: view, duration: 1.3)
            unsubscribeFromKeyboardNotifications()
            getWiFiFromSerial(serialNumber: serialnumberinput)
        } else {
            dismissKeyboard()
            let alert = MidAlertView(
                type: .alert,
                title: "Wrong Serial Number",
                message: "It looks like you are trying to enter an invalid serial number. Make sure the Serial Number you are entering is the same as the one on your PiCam",
                symbol: UIImage(systemName: "exclamationmark.circle.fill"),
                primaryAction: {
                },
                secondaryActionName: "OK",
                primaryActionName: "Learn More",
                primaryActionColor: .systemGray,
                secondaryActionColor: .systemBlue,
                secondaryAction: {}
            )
            alert.show(in: view)
        }
    }
    
    // MARK: - Animations
    func slideUp() {
        bottomConstraint.constant = 5
        animateLayout()
    }
    func slideUpQR() {
        bottomConstraintQR.constant = 5
        animateLayout()
    }
    func slideDownQR() {
        bottomConstraintQR.constant = -600
        animateLayout()
    }
    func slideUpFound() {
        bottomConstraintFound.constant = 5
        animateLayoutSlow(delay: 1.3)
    }
    func slideDownFound() {
        bottomConstraintFound.constant = -600
        animateLayout()
    }
    func slideDownFoundSlow() {
        bottomConstraintFound.constant = -600
        animateLayoutSlow(delay: 5)
    }
    
    func slideUpSlow() {
        bottomConstraint.constant = 5
        animateLayoutSlow(delay: 1)
    }
    
    func slideDown() {
        dismissKeyboard()
        bottomConstraint.constant = -600
        animateLayout()
    }
    func slideDownSlow() {
        dismissKeyboard()
        bottomConstraint.constant = -600
        animateLayoutSlow(delay: 2)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    private func animateLayout(duration: TimeInterval = 0.19) {
        UIView.animate(
            withDuration: duration,
            delay: 0.02,
            options: .curveEaseInOut,
            animations: { self.view.layoutIfNeeded() }
        )
    }
    private func animateLayoutSlow(duration: TimeInterval = 0.26, delay: TimeInterval) {
        UIView.animate(
            withDuration: duration,
            delay: delay,
            options: .curveEaseInOut,
            animations: { self.view.layoutIfNeeded() }
        )
    }
    
    // MARK: - QR Scanner Setup
    func checkCameraPermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupQRScanner()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.setupQRScanner()
                    } else {
                        self.showErrorAlert(message: "Allow camera access to continue")
                    }
                }
            }
        default:
            showErrorAlert(message: "Camera access required for QR scanning")
        }
    }
    
    // Add this property to your class
    private let sessionQueue = DispatchQueue(label: "com.picam.session.queue")
    
    // Modified setupQRScanner function
    func setupQRScanner() {
        sessionQueue.async { [weak self] in
            guard let self = self else { return }
            
            self.captureSession = AVCaptureSession()
            
            guard let videoCaptureDevice = AVCaptureDevice.default(.builtInWideAngleCamera,
                                                                   for: .video,
                                                                   position: .back) else {
                self.showErrorAlert(message: "Camera unavailable")
                
                return
            }
            
            do {
                let videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
                if self.captureSession.canAddInput(videoInput) {
                    self.captureSession.addInput(videoInput)
                }
                
                let metadataOutput = AVCaptureMetadataOutput()
                if self.captureSession.canAddOutput(metadataOutput) {
                    self.captureSession.addOutput(metadataOutput)
                    metadataOutput.setMetadataObjectsDelegate(self,
                                                              queue: DispatchQueue.main)
                    metadataOutput.metadataObjectTypes = [.qr, .code128]
                }
                
                // Configure preview layer on main thread
                DispatchQueue.main.async {
                    self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
                    self.previewLayer.frame = self.QRCodeScannerView.bounds
                    self.previewLayer.videoGravity = .resizeAspectFill
                    self.previewLayer.cornerRadius = 22
                    self.QRCodeScannerView.layer.insertSublayer(self.previewLayer, at: 0)
                }
                
                // Start session on background queue
                self.captureSession.startRunning()
                
            } catch {
                self.showErrorAlert(message: "Camera setup failed")
            }
        }
    }
    
    // When stopping the session (in connectToWiFi or elsewhere)
    func stopCaptureSession() {
        sessionQueue.async { [weak self] in
            self?.previewLayer?.removeFromSuperlayer()
            self?.captureSession.stopRunning()
        }
    }
    
    
    // MARK: - QR Processing
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let serialNumber = readableObject.stringValue else { return }
        
        captureSession.stopRunning()
        stopCaptureSession()
        if serialNumber.contains("LW") || serialNumber.contains("CE") && serialNumber.count == 9 || serialNumber.count == 12 {
            slideDownQR()
            let alert = MidAlertView(
                type: .loadingcustom,
                title: "Just a Moment",  // Ignored
                message: "",  // Ignored
                symbol: UIImage(named: "loadingspinner")
            )
            alert.show(in: view, duration: 3.1)
            getWiFiFromSerial(serialNumber: serialNumber)
        } else {
            captureSession.stopRunning()
            let alert = MidAlertView(
                type: .alert,
                title: "Invalid QR Code",
                message: "It looks like you are trying to scan an invalid QR code. Make sure the QR code you are scanning says 'Scan during Setup' or 'Serial Number' below or beside it.",
                symbol: UIImage(systemName: "viewfinder.trianglebadge.exclamationmark"),
                primaryAction: {
                },
                secondaryActionName: "Learn More",
                primaryActionName: "OK",
                primaryActionColor: .systemBlue,
                secondaryActionColor: .systemGray,
                secondaryAction: {}
            )
            alert.show(in: view)
        }
    }
    // MARK: - Firebase Integration
    func getWiFiFromSerial(serialNumber: String) {
        guard let currentUser = Auth.auth().currentUser else {
            showAuthAlert()
            return
        }
        
        let db = Firestore.firestore()
        db.collection("devices")
            .whereField("serialnum", isEqualTo: serialNumber)
            .limit(to: 1)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.showFirebaseError(error)
                    return
                }
                
                guard let document = snapshot?.documents.first else {
                    self.showInvalidSerialAlert()
                    return
                }
                let data = document.data()
                guard let deviceModel = data["modelnum"] as? String else {
                    showDeviceDetailsMissingAlert()
                    return
                }
                bottomConstraintFound.constant = 5
                animateLayoutSlow(delay: 1.2)
                DeviceModelLabel.text = "\(deviceModel)"
                DeviceModelImage.image = UIImage(named: "Picamimage")
                slideDownFoundSlow()
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
                    let alert = MidAlertView(
                        type: .loadingcustom,
                        title: "Just a moment",
                        message: "We're preparing for setup",
                        symbol: UIImage(named: "loadingspinner")
                    )
                    alert.show(in: self!.view!, duration: 2)
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 7) { [weak self] in
                    self!.processDeviceDocument(document, forUser: currentUser)
                    print("Device document proccessing")
                }
            }
    }
    // claimDevice(document: document, forUser: user, ssid: ssid, password: password, devicename: deviceName)
    private func processDeviceDocument(_ document: QueryDocumentSnapshot, forUser user: User) {
        let data = document.data()
        if let existingUserID = data["useruid"] as? String, !existingUserID.isEmpty {
            existingUserID == user.uid ? showDeviceAlreadyRegisteredAlert() : showDeviceRegisteredToOtherAlert()
            return
        }
        guard let ssid = data["wifissid"] as? String,
              let password = data["wifipassword"] as? String else {
            showMissingCredentialsAlert()
            return
        }
        guard let deviceName = data["devicename"] as? String else {
            showDeviceDetailsMissingAlert()
            return
        }
        guard let serialNum = data["serialnum"] as? String else {
            showDeviceDetailsMissingAlert()
            return
        }
        print("About to Proceed to Hotspot Page. SSID: \(ssid)")
        proceedToHotspotPage(ssid: ssid, password: password, devicename: deviceName, serialNumber: serialNum, deviceDocNum: document.documentID)
    }
    
    // MARK: - Alert Helpers
    private func showAuthAlert() {
        let alert = MidAlertView(
            type: .alert,
            title: "Not Signed In",
            message: "Sign In to your PiCam Connect account to continue",
            symbol: UIImage(systemName: "person.crop.circle.badge.questionmark.fill"),
            primaryAction: { print("insert action") },
            primaryActionName: "OK",
            primaryActionColor: .systemBlue
        )
        
        alert.show(in: view)
    }
    private func showDeviceDetailsMissingAlert() {
        let alert = MidAlertView(
            type: .alert,
            title: "An Internal Error Occurred",
            message: "Our records show that the details required to setup and connect to your device are missing. Please check our forums for more information.",
            symbol: UIImage(systemName: "questionmark.text.page.fill"),
            primaryAction: { print("insert action") },
            secondaryActionName: "Learn More",
            primaryActionName: "OK",
            primaryActionColor: .systemBlue,
            secondaryActionColor: .systemGray,
            secondaryAction: { print("insert action")},
        )
        
        alert.show(in: view)
    }
    private func showRegistrationError(_ error: Error) {
        let alert = MidAlertView(
            type: .alert,
            title: "Could Not Connect",
            message: "\(error.localizedDescription)",
            symbol: UIImage(systemName: "person.crop.circle.badge.exclamationmark.fill"),
            primaryAction: { /* action */ },
            secondaryActionName: "Learn More",
            primaryActionName: "OK",
            primaryActionColor: .systemBlue,
            secondaryActionColor: .systemGray,
            secondaryAction: {
                self.showErrorAlert(message: "{INSERT ACTION}")
            }
        )
        alert.show(in: view)
        print( "Missing WiFi credentials in device record")
    }
    
    private func showFirebaseError(_ error: Error) {
        let alert = MidAlertView(
            type: .success,
            title: "An Error Occurred",
            message: error.localizedDescription,
            symbol: UIImage(systemName: "exclamationmark.circle.fill"))
        alert.show(in: view, duration: 6)
    }
    
    private func showInvalidSerialAlert() {
        let alert = MidAlertView(
            type: .alert,
            title: "An Error Occured",
            message: "There are no currently active devices that have this serial number. Try again, or check our forums for more infomration.",
            symbol: UIImage(systemName: "exclamationmark.circle.fill"),
            primaryAction: {
                self.showErrorAlert(message: "INSERT ACTION")
            },
            primaryActionName: "OK",
            primaryActionColor: .systemBlue
        )
        alert.show(in: view)
    }
    private func showMissingCredentialsAlert() {
        let alert = MidAlertView(
            type: .alert,
            title: "Could Not Connect",
            message: "Our records show that this device has not been equipped with WiFi capability. Check our forums for more information.",
            symbol: UIImage(systemName: "person.crop.circle.badge.exclamationmark.fill"),
            primaryAction: { /* action */ },
            secondaryActionName: "Learn More",
            primaryActionName: "OK",
            primaryActionColor: .systemBlue,
            secondaryActionColor: .systemGray,
            secondaryAction: {
                self.showErrorAlert(message: "{INSERT ACTION}")
            }
        )
        alert.show(in: view)
        print( "Missing WiFi credentials in device record")
    }
    
    private func showConnectionError(_ error: Error, ssid: String, devicename: String) {
        let alert = MidAlertView(
            type: .alert,
            title: "Unable to Connect",
            message: "An error occured while connecting to \(devicename). The error was: \(error.localizedDescription)",
            symbol: UIImage(systemName: "exclamationmark.circle.fill"),
            primaryAction: { print("insert action") },
            primaryActionName: "OK",
            primaryActionColor: .systemBlue
        )
        
        alert.show(in: view)
    }
    private func showConnectionSuccess(ssid: String) {
        let alert = MidAlertView(
            type: .success,
            title: "Connected!",
            message: "Connected to \(ssid)",
            symbol: UIImage(systemName: "checkmark.circle.fill"))
        alert.show(in: view, duration: 3)
    }
    private func showDeviceAlreadyRegisteredAlert() {
        let alert = MidAlertView(
            type: .alert,
            title: "Unable to Register Device",
            message: "This device is already registered to you. Remove the device from your account to set it up again.",
            symbol: UIImage(systemName: "person.crop.circle.badge.exclamationmark.fill"),
            primaryAction: { /* action */ },
            secondaryActionName: "Learn More",
            primaryActionName: "OK",
            primaryActionColor: .systemBlue,
            secondaryActionColor: .systemGray,
            secondaryAction: {
                self.showErrorAlert(message: "Removing Device...")
            }
        )
        alert.show(in: view)
    }
    private func showDeviceRegisteredToOtherAlert() {
        let alert = MidAlertView(
            type: .alert,
            title: "Unable to Register Device",
            message: "This device is registered to someone else. If your beileve this is a mistake, please contact support.",
            symbol: UIImage(systemName: "person.crop.circle.badge.questionmark.fill"),
            primaryAction: { /* action */ },
            secondaryActionName: "Learn More",
            primaryActionName: "OK",
            primaryActionColor: .systemBlue,
            secondaryActionColor: .systemGray,
            secondaryAction: {
                self.showErrorAlert(message: "Removing Device...")
            }
        )
        alert.show(in: view)
    }
    
    // MARK: - Navigation
    // In PiCamSetupViewController
    private func proceedToHotspotPage(ssid: String, password: String, devicename: String, serialNumber: String, deviceDocNum: String) {
        // Store data temporarily (or pass via sender)
        self.ssidInfo = [ssid, password]
        self.deviceName = devicename
        self.deviceDocNum = deviceDocNum
        self.serialNumber = serialNumber
        performSegue(withIdentifier: "ShowSetupConfirmation", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "ShowSetupConfirmation",
           let destVC = segue.destination as? PiCamSetupEnableHTSPT {
            destVC.ssid = ssidInfo?[0] ?? ""
            destVC.password = ssidInfo?[1] ?? ""
            destVC.deviceName = deviceName
            destVC.deviceDocNum = deviceDocNum
            destVC.serialNumber = serialNumber
        }
    }
    private func showErrorAlert(message: String) {
        let alert = PillAlertView(message: message)
        alert.show(in: view)
    }
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        
        if notification.name == UIResponder.keyboardWillShowNotification {
            let keyboardHeight = keyboardFrame.height
            UIView.animate(withDuration: 0.3) {
                self.view.frame.origin.y = -keyboardHeight / 2 // Adjust as needed
            }
        } else if notification.name == UIResponder.keyboardWillHideNotification {
            UIView.animate(withDuration: 0.3) {
                self.view.frame.origin.y = 0
            }
        }
    }
}
