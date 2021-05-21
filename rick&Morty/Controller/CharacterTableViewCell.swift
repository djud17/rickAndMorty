//
//  CharacterTableViewCell.swift
//  rick&Morty
//
//  Created by Давид Тоноян  on 21.05.2021.
//

import UIKit

class CharacterTableViewCell: UITableViewCell {
    
    
    @IBOutlet weak var characterView: UIView!
    @IBOutlet weak var characterImageView: UIImageView!
    @IBOutlet weak var characterNameLabel: UILabel!
    @IBOutlet weak var characterStatusLabel: UILabel!
    @IBOutlet weak var characterLocationLabel: UILabel!
    @IBOutlet weak var statusColorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        characterView.layer.cornerRadius = 10
        characterView.layer.masksToBounds = true
        
        statusColorView.layer.cornerRadius = statusColorView.frame.size.width / 2
        statusColorView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
