//
//  AddVehicleDelegate.swift
//  PiCam
//
//  Created by Tyson Miles on 10/3/2025.
//


import UIKit

protocol AddVehicleDelegate: AnyObject {
    func didAddVehicle(_ vehicle: Vehicle)
}

class AddVehicleViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var makePicker: UIPickerView!
    @IBOutlet weak var modelTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var customMakeTextField: UITextField!
    
    weak var delegate: AddVehicleDelegate?
    
    let makes = ["Other", "Toyota", "Honda", "Ford", "Chevrolet", "BMW", "Mercedes"]
    var selectedMake = "Other"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        makePicker.dataSource = self
        makePicker.delegate = self
        customMakeTextField.isHidden = true
    }
    
    // Picker View Implementation
    func numberOfComponents(in pickerView: UIPickerView) -> Int { return 1 }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return makes.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return makes[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedMake = makes[row]
        customMakeTextField.isHidden = (row != 0)
    }
    
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        guard let model = modelTextField.text, !model.isEmpty,
              let name = nameTextField.text, !name.isEmpty else {
            showAlert(message: "Please fill all fields")
            return
        }
        
        let finalMake = selectedMake == "Other" ? 
            (customMakeTextField.text ?? "Unknown") : selectedMake
        
        let vehicle = Vehicle(make: finalMake, model: model, name: name)
        delegate?.didAddVehicle(vehicle)
        dismiss(animated: true)
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
