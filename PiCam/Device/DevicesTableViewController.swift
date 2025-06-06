//
//  DevicesTableViewController.swift
//  PiCam
//
//  Created by Tyson Miles on 14/3/2025.
//
import UIKit
import FirebaseFirestore
import FirebaseAuth

class DevicesTableViewController: UITableViewController {
    
    // MARK: - Properties
    private var devices: [Device] = []
    private var firestoreListener: ListenerRegistration?
    private var authHandle: AuthStateDidChangeListenerHandle?
    private let db = Firestore.firestore()
    private let spinner = UIActivityIndicatorView(style: .medium)
    private let emptyLabel = UILabel()
    @IBOutlet weak var NoDeviceView: UIView!
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupAuthStateListener()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        firestoreListener?.remove()
    }
    
    deinit {
        if let handle = authHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        NoDeviceView.isHidden = false
    }
    // MARK: - Data Parsing
    private func parseSnapshot(_ snapshot: QuerySnapshot?) {
        guard let documents = snapshot?.documents else {
            showEmptyState()
            return
        }
        
        devices = documents.compactMap { doc -> Device? in
            let data = doc.data()
            return Device(
                useruid: data["useruid"] as? String ?? "",
                serialnum: data["serialnum"] as? String ?? "",
                devicename: data["devicename"] as? String ?? "",
                modelnum: data["modelnum"] as? String ?? "",
                videohours: data["videohours"] as? Int ?? 0,
                activated: data["activated"] as? Bool ?? false,
                lastseen: data["lastseen"] as? Date ?? Date(),
                friendlyname: data["wifi_ssid"] as? String ?? "",
                wifipassword: data["wifi_password"] as? String ?? "",
                wifissid: data["friendlyname"] as? String ?? "",
                status: data["status"] as? String ?? "",
                
                
            )
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            if self.devices.isEmpty {
                self.setupUI()
            
            }
            else {
                self.NoDeviceView.isHidden = true
            }
        }
    }
    
    private func showEmptyState() {
        devices = []
        DispatchQueue.main.async {
            self.NoDeviceView.isHidden = false
        }
    }
    
    // MARK: - Authentication
    private func setupAuthStateListener() {
        authHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let self = self else { return }
            
            if user == nil {
                showErrorAlert(message: "Not logged in")
                emptyLabel.isHidden = false
            } else {
                self.spinner.startAnimating()
                self.setupFirestoreListener()
            }
        }
    }
    
    @objc private func handleLogout() {
        do {
            try Auth.auth().signOut()
        } catch {
            showErrorAlert(message: error.localizedDescription)
        }
    }
    
    // MARK: - Firestore
    private func setupFirestoreListener() {
        guard let userUID = Auth.auth().currentUser?.uid else { return }
        firestoreListener = db.collection("devices")
            .whereField("useruid", isEqualTo: userUID)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                self.spinner.stopAnimating()
                    
                if let error = error {
                    self.showErrorAlert(message: error.localizedDescription)
                    return
                }
                    
                guard let snapshot = snapshot else {
                    self.showErrorAlert(message: "Invalid snapshot")
                    return
                }
                    
                self.parseSnapshot(snapshot)
                }
        
    }
    
    // MARK: - Table View
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell", for: indexPath) as! DeviceCell
        cell.configure(with: devices[indexPath.row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let device = devices[indexPath.row]
        showDetailViewController(for: device)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // MARK: - Navigation
    private func showLoginViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let loginVC = storyboard.instantiateViewController(withIdentifier: "WelcomePCMVC")
        loginVC.modalPresentationStyle = .fullScreen
        present(loginVC, animated: true)
    }
    
    private func showDetailViewController(for device: Device) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let detailVC = storyboard.instantiateViewController(withIdentifier: "DeviceDetailViewController") as? DeviceDetailViewController else {
            return
        }
        detailVC.device = device
        navigationController?.pushViewController(detailVC, animated: true)
    }
    
    // MARK: - Error Handling
    private func showErrorAlert(message: String) {
        let alert = PillAlertView(message: message)
        alert.show(in: view)
    }
}
