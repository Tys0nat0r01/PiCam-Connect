//
//  AuthManager.swift
//  PiCam
//
//  Created by Tyson Miles on 19/3/2025.
//
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import GoogleSignIn
import AuthenticationServices

class AuthManager {
    static let shared = AuthManager()
    
    private init() {}
    
    var currentUserUID: String? {
        return Auth.auth().currentUser?.uid
    }
    var currentUserEmail: String? {
        return Auth.auth().currentUser?.email
    }
    
    // MARK: - FIRESTOREDEVICEMANAGER
    
    func addDeviceToFirestore(deviceID: String, serialnum: String, activation: Bool) {
        guard let uid = currentUserUID else { return }
        
        Firestore.firestore().collection("devices").document(deviceID).setData(["userid": uid, "activated": activation, "lastseen": FieldValue.serverTimestamp()])
    }
    
    func changeDeviceName(deviceID: String, devicename: String, activation: Bool) {
        guard let uid = currentUserUID else { return }
        Firestore.firestore().collection("devices").document(deviceID).setData(["devicename": devicename, "activated": activation, "lastseen": FieldValue.serverTimestamp()])
    }
    
    func removeDevice(deviceID: String, devicename: String, activation: Bool, userid: String) {
        guard let uid = currentUserUID else { return }
        
        Firestore.firestore().collection("devices").document(deviceID).setData(["userid": uid,"devicename": devicename, "activated": activation, "lastseen": FieldValue.serverTimestamp()])
    }
    
    // MARK: - FIREBASESIGNIN,UP,OUT
    
    func signIn(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = result?.user {
                completion(.success(user.uid))
            }
        }
    }
    
    func sendResetPasswordEmail(email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { error in
            if let error = error {
                print("Error sending password reset email: \(error)")
            }
        }
    }
    func reauthenticateWithEmail(email: String, password: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "AuthManager", code: -1, userInfo: [NSLocalizedDescriptionKey: "No authenticated user"])))
            return
        }
        
        // Create email/password credential
        let credential = EmailAuthProvider.credential(withEmail: email, password: password)
        
        // Perform reauthentication
        user.reauthenticate(with: credential) { _, error in
            if let error = error {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
    
    func signUp(email: String, password: String, completion: @escaping (Result<String, Error>) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
            } else if let user = result?.user {
                completion(.success(user.uid))
            }
        }
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
    // MARK: - GitHub Sign-In
}
