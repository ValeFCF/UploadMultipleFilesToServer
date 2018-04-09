//
//  OrdenarViewController.swift
//  ejercicio SISU
//
//  Created by Emmanuel Valentín Granados López on 05/04/18.
//  Copyright © 2018 Emmanuel Valentín Granados López. All rights reserved.
//

import UIKit
import MobileCoreServices

class OrdenarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    
    var images = [UIImage]()
    
    fileprivate var longPressGesture: UILongPressGestureRecognizer!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.imagesCollectionView.delegate = self
        self.imagesCollectionView.dataSource = self
        
        self.longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.handleLongGesture(gesture:)))
        self.imagesCollectionView.addGestureRecognizer(longPressGesture)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "movibleCell", for: indexPath) as! MovibleCollectionViewCell
        
        cell.image.image = images[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    @objc func handleLongGesture(gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
            
        case .began:
            guard let selectedIndexPath = self.imagesCollectionView.indexPathForItem(at: gesture.location(in: self.imagesCollectionView)) else {
                break
            }
            self.imagesCollectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
        case .changed:
            self.imagesCollectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view!))
        case .ended:
            self.imagesCollectionView.endInteractiveMovement()
            
        default:
            self.imagesCollectionView.cancelInteractiveMovement()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        let item = images[sourceIndexPath.item]
        images.remove(at: sourceIndexPath.item)
        images.insert(item, at: destinationIndexPath.item)
    }
    
    var textField: UITextField?
    
    func configurationTextField(textField: UITextField!) {
        if (textField) != nil {
            self.textField = textField!
            
            self.textField?.text =  UserDefaults.standard.string(forKey: "nombreAlbum")
        }
    }
    
    @IBAction func editarNombreAlbum(_ sender: Any) {
        let alert = UIAlertController(title: "Editar", message: "Edita el nombre del album", preferredStyle: UIAlertControllerStyle.alert)
        alert.addTextField(configurationHandler: configurationTextField)
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel, handler:nil))
        alert.addAction(UIAlertAction(title: "Guardar", style: .default, handler:{ (UIAlertAction) in
            
            if self.textField?.text?.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                UserDefaults.standard.set(self.textField?.text, forKey: "nombreAlbum")
            } else {
                DispatchQueue.main.async {
                    let vc_alert = UIAlertController(title: "Error", message: "Se debe de indicar un nombre", preferredStyle: .alert)
                    vc_alert.addAction(UIKit.UIAlertAction(title: "Cerrar", style: .cancel , handler: nil))
                    self.present(vc_alert, animated: true, completion: nil)
                }
            }
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func subirAlbum(_ sender: Any) {
        
        let request = try! self.createRequest(name: UserDefaults.standard.string(forKey: "nombreAlbum")! )
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print("error data task: \(error!)")
            } else {
                let httpResponse = response as? HTTPURLResponse
                print("httpResponse: \(httpResponse!)")
                
                UserDefaults.standard.removeObject(forKey: "nombreAlbum")
                
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                
                let nextViewController = storyBoard.instantiateViewController(withIdentifier: "Home")
                self.present(nextViewController, animated:true, completion:nil)
            }
        })
        
        dataTask.resume()
        
        
    }
    
    /// Create request
    ///
    /// - parameter name:    The name to be passed to web service
    ///
    /// - returns:            The `URLRequest` that was created
    
    func createRequest(name: String) throws -> URLRequest {
        let parameters = [
            "name"  : name
        ]  // build your dictionary however appropriate
        
        let boundary = generateBoundaryString()
        
        let url = URL(string: "http://localhost:8080/albums/upload")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        request.httpBody = try createBody(with: parameters, filePathKey: "files", paths: self.images, boundary: boundary)
        
        return request
    }
    
    /// Create body of the `multipart/form-data` request
    ///
    /// - parameter parameters:   The optional dictionary containing keys and values to be passed to web service
    /// - parameter filePathKey:  The optional field name to be used when uploading files. If you supply paths, you must supply filePathKey, too.
    /// - parameter paths:        The optional array of file paths of the files to be uploaded
    /// - parameter boundary:     The `multipart/form-data` boundary
    ///
    /// - returns:                The `Data` of the body of the request
    
    private func createBody(with parameters: [String: String]?, filePathKey: String, paths: [UIImage], boundary: String) throws -> Data {
        var body = Data()
        
        if parameters != nil {
            for (key, value) in parameters! {
                body.append("--\(boundary)\r\n")
                body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.append("\(value)\r\n")
            }
        }
        
        for (index, path) in paths.enumerated() {
            let mimetype = "image/jpeg"
            let nombreProvisional = "img"+String(index)
            
            let imageData: Data = UIImagePNGRepresentation(path)!
            
            body.append("--\(boundary)\r\n")
            body.append("Content-Disposition: form-data; name=\"\(filePathKey)\"; filename=\"\( nombreProvisional )\"\r\n")
            body.append("Content-Type: \(mimetype)\r\n\r\n")
            body.append(imageData)
            body.append("\r\n")
        }
        
        body.append("--\(boundary)--\r\n")
        return body
    }
    
    /// Create boundary string for multipart/form-data request
    ///
    /// - returns:            The boundary string that consists of "Boundary-" followed by a UUID string.
    
    private func generateBoundaryString() -> String {
        return "Boundary-\(UUID().uuidString)"
    }

}

extension Data {
    
    /// Append string to Data
    ///
    /// Rather than littering my code with calls to `data(using: .utf8)` to convert `String` values to `Data`, this wraps it in a nice convenient little extension to Data. This defaults to converting using UTF-8.
    ///
    /// - parameter string:       The string to be added to the `Data`.
    
    mutating func append(_ string: String, using encoding: String.Encoding = .utf8) {
        if let data = string.data(using: encoding) {
            append(data)
        }
    }
}

