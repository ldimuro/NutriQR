//
//  ViewController.swift
//  NutriQR
//
//  Created by Lou DiMuro on 10/8/19.
//  Copyright © 2019 Lou DiMuro. All rights reserved.
//

import UIKit
import AVFoundation
import QRCodeReader
import FirebaseDatabase

class ViewController: UIViewController, QRCodeReaderViewControllerDelegate {
  
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var foodLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var calorieLabel: UILabel!
    @IBOutlet weak var calorieTitle: UILabel!
    @IBOutlet weak var ingredientTitle: UILabel!
//    @IBOutlet weak var ingredientLabel: UILabel!
    
    @IBOutlet weak var isVeganTitle: UILabel!
    @IBOutlet weak var isVeganField: UILabel!
    @IBOutlet weak var fatField: UILabel!
    @IBOutlet weak var cholesterolField: UILabel!
    @IBOutlet weak var sodiumField: UILabel!
    @IBOutlet weak var fiberField: UILabel!
    @IBOutlet weak var sugarField: UILabel!
    @IBOutlet weak var proteinField: UILabel!
    @IBOutlet weak var totalFatTitle: UILabel!
    @IBOutlet weak var cholesterolTitle: UILabel!
    @IBOutlet weak var sodiumTitle: UILabel!
    @IBOutlet weak var fiberTitle: UILabel!
    @IBOutlet weak var sugarTitle: UILabel!
    @IBOutlet weak var proteinTitle: UILabel!
    
    
    // VARIABLES
    var name : String = ""
    var price : String = ""
    var foodDescription : String = ""
    var calories : Int = 0
    var cholesterol : String = ""
    var fiber : String = ""
    var sodium : String = ""
    var sugar : String = ""
    var protein : String = ""
    var totalFat : String = ""
    var isVegan : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scanButton.layer.cornerRadius = 10
        foodLabel.numberOfLines = 0
        
    }
    
    // Good practice: create the reader lazily to avoid cpu overload during the
    // initialization and each time we need to scan a QRCode
    lazy var readerVC: QRCodeReaderViewController = {
        let builder = QRCodeReaderViewControllerBuilder {
            $0.reader = QRCodeReader(metadataObjectTypes: [.qr], captureDevicePosition: .back)
            
            // Configure the view controller (optional)
            $0.showTorchButton        = false
            $0.showSwitchCameraButton = false
            $0.showCancelButton       = false
            $0.showOverlayView        = true
            $0.rectOfInterest         = CGRect(x: 0.2, y: 0.2, width: 0.6, height: 0.6)
        }
        
        return QRCodeReaderViewController(builder: builder)
    }()
    
    @IBAction func scanAction(_ sender: Any) {
        // Retrieve the QRCode content by using the delegate pattern
        readerVC.delegate = self
        
        // Or by using the closure pattern
        readerVC.completionBlock = { (result: QRCodeReaderResult?) in
            let data = result!.value
            print(data)
            
            self.scanDatabase(input: data)
        
        }

        // Presents the readerVC as modal form sheet
        readerVC.modalPresentationStyle = .formSheet
        
        present(readerVC, animated: true, completion: nil)
    }
    
    func scanDatabase(input : String) {
        var ref: DatabaseReference!

        ref = Database.database().reference().child("items").child(input)
        
        ref.observeSingleEvent(of: .value) { snapshot in
            print(snapshot.childrenCount) // I got the expected number of items
            for rest in snapshot.children.allObjects as! [DataSnapshot] {
                print("\(rest.key) = \(rest.value!)")
                
                switch rest.key {
                case "calories":
                    self.calories = rest.value as! Int
                    
                case "cholesterol":
                    self.cholesterol = rest.value! as! String
                    
                case "description":
                    self.foodDescription = rest.value! as! String
                    
                case "fiber":
                    self.fiber = rest.value! as! String
                    
                case "isVegan":
                    self.isVegan = rest.value! as! Int
                    
                case "name":
                    self.name = rest.value! as! String
                    
                case "price":
                    self.price = rest.value! as! String
                    
                case "protein":
                    self.protein = rest.value! as! String
                    
                case "sodium":
                    self.sodium = rest.value! as! String
                    
                case "sugar":
                    self.sugar = rest.value! as! String
                    
                case "totalFat":
                    self.totalFat = rest.value! as! String
                default:
                    print("ERROR")
                }
            }
            
            print("ALL DONE GETTING DATA")
            
            // ADD TITLES TO PAGE
            self.foodLabel.isHidden = false
            self.priceLabel.isHidden = false
            self.descriptionLabel.isHidden = false
            self.calorieTitle.isHidden = false
            self.calorieLabel.isHidden = false
            self.isVeganField.isHidden = false
            self.isVeganTitle.isHidden = false
            self.ingredientTitle.isHidden = false
            self.totalFatTitle.isHidden = false
            self.cholesterolTitle.isHidden = false
            self.sodiumTitle.isHidden = false
            self.fiberTitle.isHidden = false
            self.sugarTitle.isHidden = false
            self.proteinTitle.isHidden = false
            self.fatField.isHidden = false
            self.cholesterolField.isHidden = false
            self.sodiumField.isHidden = false
            self.fiberField.isHidden = false
            self.sugarField.isHidden = false
            self.proteinField.isHidden = false
            
            // POPULATE DATA FIELDS
            self.foodLabel.text = self.name
            self.priceLabel.text = self.price
            self.descriptionLabel.text = self.foodDescription
            self.calorieLabel.text = "\(self.calories)"
            self.fatField.text = self.totalFat
            self.cholesterolField.text = self.cholesterol
            self.sodiumField.text = self.sodium
            self.fiberField.text = self.fiber
            self.sugarField.text = self.sugar
            self.proteinField.text = self.protein

            if(self.isVegan == 0) {
                self.isVeganField.text = "❌"
            }
            else if(self.isVegan == 1) {
                self.isVeganField.text = "✅"
            }
        }
    }
    
    // MARK: - QRCodeReaderViewController Delegate Methods

    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        reader.stopScanning()

        dismiss(animated: true, completion: nil)
    }

    //This is an optional delegate method, that allows you to be notified when the user switches the cameraName
    //By pressing on the switch camera button
    func reader(_ reader: QRCodeReaderViewController, didSwitchCamera newCaptureDevice: AVCaptureDeviceInput) {
        //if let cameraName = newCaptureDevice.device.localizedName {
          //print("Switching capture to: \(cameraName)")
            print("Switching capture to: \(newCaptureDevice.device.localizedName)")
        //}
    }

    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        
        print("STOPPED SCANNING");

        dismiss(animated: true, completion: nil)
    }


}

