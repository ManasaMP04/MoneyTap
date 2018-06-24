//
//  WikiSearchCell.swift
//  Assignment
//
//  Created by Manasa MP on 23/06/18.
//  Copyright © 2018 Manasa MP. All rights reserved.
//

import UIKit

protocol WikiSearchCellDelegate:class {
    
    func wikiSearchCell(_ cell: WikiSearchCell, isSelected: Bool)
}

class WikiSearchCell: UITableViewCell {

    @IBOutlet fileprivate weak var imageview        : UIImageView!
    @IBOutlet fileprivate weak var titleLabel       : UILabel!
    @IBOutlet fileprivate weak var descriptionLabel : UILabel!
    @IBOutlet fileprivate weak var cardView         : UIView!
    @IBOutlet fileprivate weak var shortListButton  : UIButton!
    
    static let cellId = "WikiSearchCell"
    weak var delegate : WikiSearchCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        cardView.addShadowWithColor(UIColor.black)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
    }
   
    func showSearchData(_ data: SearchResult) {
        
        titleLabel.text = data.title
        
        // if data under terms is static then We can create a model class for this terms object, else we can check the value using key value pair
        
        if let descArray = data.terms["description"] as? NSArray, descArray.count > 0,
            let str = descArray[0] as? String {
            
             descriptionLabel.text = str
        }else {descriptionLabel.text = ""}
       
        guard let str = data.thumbnail?.source else {return}
        
        let imageUrl = URL(string: str)
        imageview.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "Placeholder"))
        isRecordExist(data)
    }
    
    @IBAction func shortListButtonTapped(_ sender: Any) {
    
        shortListButton.isSelected = !shortListButton.isSelected
        self.delegate?.wikiSearchCell(self, isSelected: shortListButton.isSelected)
    }
}

//Mark:- Private Method

extension WikiSearchCell {
    
    fileprivate func isRecordExist(_ data: SearchResult) {
        
         let predicate = "pageId == %ld && title == \"%@\""
         let str = String(format: predicate, data.pageid, data.title)
        
        if let searchRecords = CoreData.isSearchExisting(.saveData, prediacteFormat: str),
            let _ = searchRecords.first {
            
            shortListButton.isSelected = true
        }else {
            
            shortListButton.isSelected = false
        }
    }
}
