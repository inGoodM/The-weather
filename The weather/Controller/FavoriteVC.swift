//
//  FavoriteVC.swift
//  The weather
//
//  Created by InGMood on 21.03.2023.
//

import UIKit

class FavoriteVC: UIViewController, UIApplicationDelegate {

    
    @IBOutlet weak var tableViewFavor: UITableView!
    
    struct FavorData {
        var titleCity: String
        var imageWeather: UIImage
        var tempCity: Int
    }
    
    var arrayFavorData: [FavorData] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableViewFavor.dataSource = self
        tableViewFavor.delegate = self
        
    }
 
 
}

extension FavoriteVC:  UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableViewFavor.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "Here is will be Favorite"
        
        return cell
    }
    
    
}
