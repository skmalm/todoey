//
//  CategoryTableViewCell.swift
//  todoey
//
//  Created by Sebastian Malm on 6/13/20.
//  Copyright © 2020 SebastianMalm. All rights reserved.
//

import UIKit

class CategoryTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBOutlet weak var label: UILabel!

    
}
