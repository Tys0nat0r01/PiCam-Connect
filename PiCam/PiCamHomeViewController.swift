//  ViewController.swift
import UIKit
import AVKit

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var deviceNameLabel: UILabel!
    let serverPort = 5000
    var serverIP = "192.168.4.1"
    var files: [String] = []
    var device: Device!
    var isNEWSIGNEDINUser: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        loadFileList()
        checkForFirstSignIN()
        loadCurrentDeviceName()
    }
    
    func loadCurrentDeviceName() {
        if let deviceName = Core.shared.getCurrentDeviceName() {
            deviceNameLabel.text = deviceName
        } else {
            let defaultDeviceName = "No Device"
            Core.shared.setCurrentDeviceName(defaultDeviceName)
            deviceNameLabel.text = defaultDeviceName
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if Core.shared.isNewUser() {
            let vc = storyboard?.instantiateViewController(withIdentifier: "welcome") as! WelcomeViewController
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
    }
    
    private func setupCollectionView() {
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UINib(nibName: "VideoCell", bundle: nil), forCellWithReuseIdentifier: "VideoCell")
        
    }
    func checkForFirstSignIN() {
        if Core.shared.isNewUser() && isNEWSIGNEDINUser == true {
            let NewUserVC = storyboard?.instantiateViewController(withIdentifier: "welcome") as! WelcomeViewController
            NewUserVC.modalPresentationStyle = .fullScreen
            present(NewUserVC, animated: true)
        }
    }

    private func loadFileList() {
        guard let url = URL(string: "http://\(serverIP):\(serverPort)/files") else { return }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            guard let data = data, error == nil else { return }
            
            if let files = try? JSONDecoder().decode([String].self, from: data) {
                DispatchQueue.main.async {
                    self?.files = files
                    self?.collectionView.reloadData()
                }
            }
        }.resume()
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return files.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "VideoCell", for: indexPath) as! VideoCell
        let fileName = files[indexPath.row]
        
        cell.configure(
            fileName: fileName,
            thumbnailURL: URL(string: "http://\(serverIP):\(serverPort)/thumbnail/\(fileName.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")")
        )
        
        cell.onViewTapped = { [weak self] in
            self?.showVideoPlayer(for: fileName)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 20
        let collectionViewSize = collectionView.frame.size.width - padding
        return CGSize(width: collectionViewSize/2, height: 200)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    private func showVideoPlayer(for fileName: String) {
        // Same as previous implementation
    }

}
class Core {
    
    static let shared = Core()
    
    func isNewUser() -> Bool {
        return !UserDefaults.standard.bool(forKey: "isNewUser")
    }
    
    func setIsNotNewUser() {
        UserDefaults.standard.set(true, forKey: "isNewUser")
    }
    func setIsNewUser() {
        UserDefaults.standard.set(false, forKey: "isNewUser")
    }
    func getCurrentDeviceName() -> String? {
            return UserDefaults.standard.string(forKey: "CurrentDevice")
    }
        
    func setCurrentDeviceName(_ name: String) {
        UserDefaults.standard.set(name, forKey: "CurrentDevice")
    }
        
    func getDeviceDetails(for deviceName: String) -> Device? {
        if let data = UserDefaults.standard.data(forKey: "Device_\(deviceName)"),
            let device = try? JSONDecoder().decode(Device.self, from: data) {
            return device
        }
        return nil
    }
        
    func saveDeviceDetails(_ device: Device) {
        if let data = try? JSONEncoder().encode(device) {
            UserDefaults.standard.set(data, forKey: "Device_\(device.devicename)")
        }
    }
}
