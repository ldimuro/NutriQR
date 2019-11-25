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

class ViewController: UIViewController, QRCodeReaderViewControllerDelegate {
  
    @IBOutlet weak var scanButton: UIButton!
    @IBOutlet weak var foodLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var calorieLabel: UILabel!
    @IBOutlet weak var calorieTitle: UILabel!
    @IBOutlet weak var ingredientTitle: UILabel!
//    @IBOutlet weak var ingredientLabel: UILabel!
    
    
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
            
            let dataArr = data.split(separator: "|")
            
            let foodName = dataArr[0]
            let foodDesc = dataArr[1]
            let price = dataArr[2]
            let calories = dataArr[3]
            let ingredients = dataArr[4]
            
//            var count = 0;
//            for each in dataArr {
//                count += 1
//                print("\(count). \(each)");
//            }
//            self.foodLabel.lineBreakMode = .byWordWrapping
//            self.foodLabel.numberOfLines = 0;
            
            print(calories)
            print(ingredients)
            
            
            self.calorieTitle.text = "Calories"
            self.ingredientTitle.text = "Ingredients"
            self.foodLabel.text = foodName.uppercased()
            self.descriptionLabel.text = foodDesc.lowercased()
            self.priceLabel.text = price.lowercased()
            self.calorieLabel.text = calories.lowercased()
//            self.ingredientLabel.text = ingredients.lowercased()
            
        }

        // Presents the readerVC as modal form sheet
        readerVC.modalPresentationStyle = .formSheet
        
        present(readerVC, animated: true, completion: nil)
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

