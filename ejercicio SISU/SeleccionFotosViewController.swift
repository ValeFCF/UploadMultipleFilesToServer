//
//  SeleccionFotosViewController.swift
//  ejercicio SISU
//
//  Created by Emmanuel Valentín Granados López on 05/04/18.
//  Copyright © 2018 Emmanuel Valentín Granados López. All rights reserved.
//

import UIKit
import Photos

class SeleccionFotosViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var photosCollectionView: UICollectionView!
    
    var images = [PHAsset]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.photosCollectionView.delegate = self
        self.photosCollectionView.dataSource = self
        
        self.photosCollectionView.allowsMultipleSelection = true
        //self.photosCollectionView.sele

        // Do any additional setup after loading the view.
        
        //Photos
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .notDetermined {
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized{
                    self.getImages()
                } else {
                    let vc_alert = UIAlertController(title: nil, message: "No podremos obtener las fotos del carrete, autoriza el permiso en Configuración del iPhone", preferredStyle: .alert)
                    vc_alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel , handler: nil))
                    self.present(vc_alert, animated: true, completion: nil)
                }
            })
        } else {
            // no entrará a menos que tenga permiso
            self.getImages()
        }
    }
    
    func getImages() {
        let assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
        assets.enumerateObjects({ (object, count, stop) in
            self.images.append(object)
        })
        
        //Ordenar primer imagen primero
        self.images.reverse()
        
         DispatchQueue.main.async {
            // recargar el collection View
            self.photosCollectionView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FotoCollectionViewCell", for: indexPath) as! FotoCollectionViewCell
        let asset = images[indexPath.row]
        let manager = PHImageManager.default()
        if cell.tag != 0 {
            manager.cancelImageRequest(PHImageRequestID(cell.tag))
        }
        cell.tag = Int(manager.requestImage(for: asset,
                                            targetSize: CGSize(width: 120.0, height: 120.0),
                                            contentMode: .aspectFill,
                                            options: nil) { (result, _) in
                                                cell.fotoImageView?.image = result
        })
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! FotoCollectionViewCell
        
        cell.imgCellSelected.alpha = 1
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! FotoCollectionViewCell
        
        cell.imgCellSelected.alpha = 0.4
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
    

    // MARK: - Navigation
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if identifier == "ordenarFotos" {
            if self.photosCollectionView.indexPathsForSelectedItems?.count == 0 {
                
                let vc_alert = UIAlertController(title: nil, message: "Selecciona alguna imagen del carrete", preferredStyle: .alert)
                vc_alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel , handler: nil))
                self.present(vc_alert, animated: true, completion: nil)
                
                return false
            }
        }
        return true
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "ordenarFotos" {
            
            var imagesSelected = [UIImage] ()
            
            for indexPath in self.photosCollectionView.indexPathsForSelectedItems! {
                
                let cell = self.photosCollectionView.cellForItem(at: indexPath) as! FotoCollectionViewCell
                
                imagesSelected.append( cell.fotoImageView.image! )
            }
           
            (segue.destination as! OrdenarViewController).images = imagesSelected
        }
    }

}
