//
//  DetailVC.swift
//  Assignment
//
//  Created by Manasa MP on 23/06/18.
//  Copyright © 2018 Manasa MP. All rights reserved.
//

import UIKit

class DetailVC: UIViewController {
    
    @IBOutlet fileprivate weak var titleLabel           : UILabel!
    @IBOutlet fileprivate weak var webView              : UIWebView!
    
    fileprivate var activityIndicator                   : UIActivityIndicatorView?
    
    var titleString = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        guard Reachability.connectedToNetwork() else {showAlertView();return}
        
        loadWebView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}

//Mark:- IBActions

extension DetailVC {
    
    @IBAction func backButtonTapped(_ sender: Any) {
        
        self.navigationController?.popViewController(animated: true)
    }
}

//Mark:- Private Methods

extension DetailVC {
    
    fileprivate func setup() {
        
        activityIndicator = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
        self.view.addSubview(activityIndicator!)
        activityIndicator?.center = view.center
        titleLabel.text = titleString
    }
    
    fileprivate func showAlertView() {
        
        let atertVC = UIAlertController.init(title: "Error", message: "Please check Your Internet", preferredStyle: .alert)
        let alert = UIAlertAction.init(title: "OK", style: .cancel) { (action) in
            
            self.navigationController?.popViewController(animated: true)
        }
        
        atertVC.addAction(alert)
        present(atertVC, animated: true, completion: nil)
    }
    
    fileprivate func loadWebView() {
        
        let urlString = "https://en.wikipedia.org/wiki"
        
        if var url = URL(string: urlString) {
            
            activityIndicator?.startAnimating()
            url.appendPathComponent(titleString)
            let request     = URLRequest(url: url)
            webView.loadRequest(request)
        }
        
    }
}

extension DetailVC: UIWebViewDelegate {
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        
        activityIndicator?.stopAnimating()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        
        activityIndicator?.stopAnimating()
    }
}

