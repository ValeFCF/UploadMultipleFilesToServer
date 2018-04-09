//
//  NombreAlbumViewController.swift
//  ejercicio SISU
//
//  Created by Emmanuel Valentín Granados López on 05/04/18.
//  Copyright © 2018 Emmanuel Valentín Granados López. All rights reserved.
//

import UIKit

class NombreAlbumViewController: UIViewController {

    @IBOutlet weak var nombreLabel: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.nombreLabel.resignFirstResponder()
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func hideKeyboard() {
        view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func buttonCreate(_ sender: Any) {
        
        if self.nombreLabel.text!.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            let vc_alert = UIAlertController(title: "Error", message: "Se debe de indicar un nombre", preferredStyle: .alert)
            vc_alert.addAction(UIAlertAction(title: "Cerrar", style: .cancel , handler: nil))
            self.present(vc_alert, animated: true, completion: nil)
        } else {
            
            UserDefaults.standard.set(self.nombreLabel.text, forKey: "nombreAlbum")
            
            performSegue(withIdentifier: "seleccionarFotos", sender: nil)
        }
        
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
