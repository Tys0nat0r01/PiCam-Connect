//
//  VehicleDetailsViewController.swift
//  PiCam
//
//  Created by Tyson Miles on 10/3/2025.
//
import UIKit

class VehicleDetailsViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var formView: UIView!
    @IBOutlet weak var makeTextField: UITextField!
    @IBOutlet weak var modelTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let makes = ["Other", "Toyota", "Honda", "Ford", "Chevrolet", "BMW"]
    var vehicles: [Vehicle] = []
    var activeTextField: UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPicker()
        setupForm()
        setupTapGesture()
    }
    
    func setupPicker() {
        let pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        makeTextField.inputView = pickerView
        
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissPicker))
        toolbar.setItems([doneButton], animated: true)
        makeTextField.inputAccessoryView = toolbar
    }
    
    func setupForm() {
        formView.isHidden = true
        formView.layer.cornerRadius = 10
        formView.layer.shadowColor = UIColor.black.cgColor
        formView.layer.shadowOpacity = 0.2
        formView.layer.shadowOffset = CGSize(width: 0, height: 2)
        formView.layer.shadowRadius = 4
    }
    
    func setupTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissPicker() {
        view.endEditing(true)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Picker View Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return makes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return makes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        makeTextField.text = makes[row]
    }
    
    // MARK: - Button Actions
    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        if vehicles.count < 5 {
            formView.isHidden = false
            resetForm()
        } else {
            showAlert(title: "Limit Reached", message: "You can only add up to 5 vehicles.")
        }
    }
    
    @IBAction func saveTapped(_ sender: UIButton) {
        guard validateForm() else { return }
        
        let vehicle = Vehicle(
            make: makeTextField.text!,
            model: modelTextField.text!,
            name: nameTextField.text!
        )
        
        vehicles.append(vehicle)
        addVehicleCard(vehicle)
        formView.isHidden = true
    }
    
    @IBAction func cancelTapped(_ sender: UIButton) {
        formView.isHidden = true
    }
    
    // MARK: - Helper Methods
    func resetForm() {
        makeTextField.text = nil
        modelTextField.text = nil
        nameTextField.text = nil
    }
    
    func validateForm() -> Bool {
        guard !(makeTextField.text?.isEmpty ?? true) else {
            showAlert(title: "Error", message: "Please select a make")
            return false
        }
        
        if makeTextField.text == "Other" {
            makeTextField.text = nameTextField.text // Using name field for custom make
        }
        
        guard !(modelTextField.text?.isEmpty ?? true) else {
            showAlert(title: "Error", message: "Please enter model")
            return false
        }
        
        guard !(nameTextField.text?.isEmpty ?? true) else {
            showAlert(title: "Error", message: "Please enter name")
            return false
        }
        
        return true
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func addVehicleCard(_ vehicle: Vehicle) {
        let card = UIView()
        card.backgroundColor = .systemBackground
        card.layer.cornerRadius = 12
        card.layer.borderWidth = 1
        card.layer.borderColor = UIColor.systemGray5.cgColor
        
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        let labels = [
            ("Make: \(vehicle.make)", UIFont.boldSystemFont(ofSize: 16)),
            ("Model: \(vehicle.model)", UIFont.systemFont(ofSize: 14)),
            ("Name: \(vehicle.name)", UIFont.systemFont(ofSize: 14))
        ]
        
        for (text, font) in labels {
            let label = UILabel()
            label.text = text
            label.font = font
            stack.addArrangedSubview(label)
        }
        
        card.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
            stack.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
            stack.bottomAnchor.constraint(equalTo: card.bottomAnchor, constant: -16)
        ])
        
        stackView.addArrangedSubview(card)
        card.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor, constant: -32).isActive = true
    }
}
