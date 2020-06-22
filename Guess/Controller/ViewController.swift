//
//  ViewController.swift
//  Guess
//
//  Created by Asaduzzaman Anik on 6/21/20.
//  Copyright © 2020 Asaduzzaman Anik. All rights reserved.
//

import UIKit
import Vision
import CoreML

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var backgroundImage: UIImageView!
    @IBOutlet weak var testImage: UIImageView!
    @IBOutlet weak var predictionLabel: UILabel!
    
    let imagePicker = UIImagePickerController()
    var predictionResult: [VNClassificationObservation] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker.delegate = self
        
        
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.regular)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundImage.addSubview(blurEffectView)

    }
    
    func giveClassification(testImage: CIImage) {
        guard let modelResnet50 = try? VNCoreMLModel(for: Resnet50().model) else{
            fatalError("Something wrong with the model")
        }
        
        let request = VNCoreMLRequest(model: modelResnet50) { (request, error) in
            guard let results = request.results as? [VNClassificationObservation],
                let firstPrediction = results.first
            else{
                fatalError("unable to retrive prediction")
            }
            DispatchQueue.main.async {
                
                self.predictionLabel.text = firstPrediction.identifier.uppercased()
                
                
                
            }
            
        }
        
        let handler = VNImageRequestHandler(ciImage: testImage)
        
        do{
            try handler.perform([request])
        }
        catch {
            print(error)
        }
        
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage{
            testImage.image = image
            backgroundImage.image = image
            imagePicker.dismiss(animated: true, completion: nil)
            guard let ciImage = CIImage(image: image) else {
                fatalError("Unable to convert image to ciImage")
            }
            giveClassification(testImage: ciImage)
        }
    }
    
    @IBAction func acquirePhoto(_ sender: UIButton) {
        
        switch sender.tag {
        case 1:
            imagePicker.sourceType = .camera
        case 2:
            imagePicker.sourceType = .photoLibrary
        default:
            imagePicker.sourceType = .camera
        }
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
        
    }
    
}

