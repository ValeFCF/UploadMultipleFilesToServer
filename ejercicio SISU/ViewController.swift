//
//  ViewController.swift
//  ejercicio SISU
//
//  Created by Emmanuel Valentín Granados López on 05/04/18.
//  Copyright © 2018 Emmanuel Valentín Granados López. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
     var albumes = [[String : Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        let request = NSMutableURLRequest(url: NSURL(string: "http://localhost:8080/albums")! as URL,
                                          cachePolicy: .useProtocolCachePolicy,
                                          timeoutInterval: 10.0)
        request.httpMethod = "GET"
        
        let session = URLSession.shared
        let dataTask = session.dataTask(with: request as URLRequest, completionHandler: { (data, response, error) -> Void in
            if (error != nil) {
                print(error!)
            } else {
                if (response as! HTTPURLResponse).statusCode == 200 {
                    if let json = try? JSONSerialization.jsonObject(with: data!, options: []) {
                        DispatchQueue.main.async {
                            
                            if self.albumes.count > 0 {
                                self.albumes.removeAll()
                            }
                            
                            if let jsonResult = json as? [[String : Any]] {
                                for dato in jsonResult {
                                    self.albumes.append(dato)
                                }
                                
                            }
                            
                            self.tableView.reloadData()
                        }
                        
                    } else {
                        print("HTTP Status Code: 200")
                        print("El JSON de respuesta es inválido.")
                    }
                } else {
                    
                    DispatchQueue.main.async {
                        if (try? JSONSerialization.jsonObject(with: data!, options: [])) != nil {
                            let vc_alert = UIAlertController(title: nil, message: "Ocurrió un error en el servidor", preferredStyle: .alert)
                            vc_alert.addAction(UIAlertAction(title: "OK", style: .cancel , handler: nil))
                            self.present(vc_alert, animated: true, completion: nil)
                            
                            
                        } else {
                            print("HTTP Status Code: 400 o 500")
                            print("El JSON de respuesta es inválido.")
                        }
                    }
                }
            }
        })
        
        dataTask.resume()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.albumes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellAlbum", for: indexPath) as! AlbumCell
        
        cell.nombreAlbumlbl.text = self.albumes[indexPath.row]["name"] as? String
        
        return cell
    }
}

