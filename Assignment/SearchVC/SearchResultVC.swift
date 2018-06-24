//
//  SearchResultVC.swift
//  Assignment
//
//  Created by Manasa MP on 23/06/18.
//  Copyright © 2018 Manasa MP. All rights reserved.
//

import UIKit
import AlamofireObjectMapper
import Alamofire
import SystemConfiguration

class SearchResultVC: UIViewController {

    @IBOutlet fileprivate weak var tableview        : UITableView!
    @IBOutlet fileprivate weak var searchbar        : UISearchBar!
    @IBOutlet fileprivate weak var searchBarHeight  : NSLayoutConstraint!
    
    fileprivate var searchResults                   = [SearchResult]()
    fileprivate var activityIndicator               : UIActivityIndicatorView?
    fileprivate let screenWidth                     = UIScreen.main.bounds.size.width
    
    override func viewDidLoad() {
        super.viewDidLoad()

       setup()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
}

//Mark:- Private Methods

extension SearchResultVC {
    
    fileprivate func setup() {
        
        tableview.register(UINib(nibName: "WikiSearchCell", bundle: nil), forCellReuseIdentifier: WikiSearchCell.cellId)
        tableview.tableFooterView = UIView()
        tableview.estimatedRowHeight = 60
        activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
        self.view.addSubview(activityIndicator!)
        activityIndicator?.center = view.center
        callApi("sachin")
    }
    
    fileprivate func callApi(_ searchText: String) {
        
        guard Reachability.connectedToNetwork() else {fetchLocalData();return}
        
        activityIndicator?.startAnimating()
        Alamofire.request(SearchRouter.get(searchText))
            .responseArray(keyPath: "query.pages") { (response: DataResponse<[SearchResult]>) in
                
                self.activityIndicator?.stopAnimating()
                guard let values = response.result.value else {return}
                
                self.searchResults = values
                self.tableview.reloadData()
        }
    }
    
    fileprivate func fetchLocalData() {
        
        guard let searchResultArray = CoreData.fetchAllRecords(.saveData), searchResultArray.count > 0 else {showAlertView(); return}
        
        for item in searchResultArray {
            
            if  let pageId = item.value(forKey: "pageId") as? Int,
                let title = item.value(forKey: "title") as? String,
                let imageStr = item.value(forKey: "imageStr") as? String,
                let desc = item.value(forKey: "descriptionData") as? String {
                
                let result = SearchResult.init(pageId, title: title, imageStr: imageStr, desc: desc)
                searchResults.append(result)
            }
        }
        
        tableview.reloadData()
    }
    
    fileprivate func showAlertView() {
        
        let atertVC = UIAlertController.init(title: "Error", message: "Please check Your Internet", preferredStyle: .alert)
        let alert = UIAlertAction.init(title: "OK", style: .cancel, handler: nil)
        
        atertVC.addAction(alert)
        present(atertVC, animated: true, completion: nil)
    }
    
    // depending on data size we need to save, we can use Core Data, Plist, NSUserDefault or save complete JSon as file.
    
    fileprivate func saveData(_ data: SearchResult) {
        
        var desc = ""
        
        if let descArray = data.terms["description"] as? NSArray, descArray.count > 0,
            let str = descArray[0] as? String {
        
            desc = str
        }
        
        let dict = ["pageId": data.pageid, "title": data.title, "descriptionData":  desc, "imageStr": (data.thumbnail?.source ?? "")] as [String : Any]
        CoreData.saveToDB(withDBName: .saveData, data: dict)
    }
    
    fileprivate func deleteRecord(_ data: SearchResult) {
        
        let predicate = "pageId == %ld && title == \"%@\""
        let str = String(format: predicate, data.pageid, data.title)
        
        guard let searchRecords = CoreData.isSearchExisting(.saveData, prediacteFormat: str),
            let record = searchRecords.first else{return}
        CoreData.deleteLastRecord(record)
        tableview.reloadData()
    }
}

//Mark:- IBActions

extension SearchResultVC: WikiSearchCellDelegate {
    
    func wikiSearchCell(_ cell: WikiSearchCell, isSelected: Bool) {
        
        guard let indexPath = tableview.indexPath(for: cell) else {return}
        
        if isSelected {saveData(searchResults[indexPath.row])}
        else {deleteRecord(searchResults[indexPath.row])}
    }
}

//Mark:- IBActions

extension SearchResultVC {
    
    @IBAction func searchButtonTapped(_ sender: Any) {
        
       UIView.animate(withDuration: 0.7) {
            
            self.searchBarHeight.constant = (self.searchBarHeight.constant == 56) ? 0 : 56
        }
    }
}

//Mark:- UITableViewDataSource, UITableViewDelegate

extension SearchResultVC: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: WikiSearchCell.cellId, for: indexPath) as! WikiSearchCell
        cell.showSearchData(searchResults[indexPath.row])
        cell.delegate = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableViewAutomaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let vc = storyboard.instantiateViewController(withIdentifier: "DetailVC") as? DetailVC else{return}
        
        vc.titleString = searchResults[indexPath.row].title
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//Mark:- UISearchBarDelegate

extension SearchResultVC: UISearchBarDelegate, UITextFieldDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        UIView.animate(withDuration: 0.7) {
            
             self.searchBarHeight.constant = 56
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        view.endEditing(true)
        guard let txt = searchBar.text else {
            return
        }
        callApi(txt)
    }
}

// Added Extension for UIVIEW for Shadow. We can create separate file to write all Extensions

extension UIView {
    
    func addShadowWithColor(_ color: UIColor, offset: CGSize=CGSize(width: 1, height: 1), opacity: Float=0.20, radius: CGFloat=3) {
        
        self.layer.shadowColor      = color.cgColor
        self.layer.shadowOffset     = offset
        self.layer.shadowOpacity    = opacity
        self.layer.shadowRadius     = radius
        self.layer.masksToBounds    = false
    }
}

extension UIColor {
    
    static func colorWithHex (_ hex : Int, alpha: CGFloat=1.0) -> UIColor {
        
        let cmp = (
            r : CGFloat(((hex >> 16) & 0xFF))/255.0,
            g : CGFloat(((hex >> 08) & 0xFF))/255.0,
            b : CGFloat(((hex >> 00) & 0xFF))/255.0
        )
        
        return UIColor(red: cmp.r, green: cmp.g, blue: cmp.b, alpha: alpha)
    }
}

class Reachability {
    
   static func connectedToNetwork() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
}
