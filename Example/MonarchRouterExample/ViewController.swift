//
//  ViewController.swift
//  MonarchRouterExample
//
//  Created by Eliah Snakin on 16/11/2018.
//  Copyright © 2018 nikans.com. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    func configure(title: String, buttonTitle: String?, buttonAction: (()->())?, backgroundColor: UIColor)
    {
        self.title = title
        self.titleString = title
        self.buttonTitleString = buttonTitle
        self.buttonAction = buttonAction
        self.backgroundColor = backgroundColor
    }
    
    private var titleString: String!
    private var buttonTitleString: String?
    private var buttonAction: (()->())?
    private var backgroundColor: UIColor!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.titleLabel.text = title
        
        if let buttonTitle = buttonTitleString {
            self.button.setTitle(buttonTitle, for: .normal)
        }
        button.isHidden = buttonTitleString == nil
        
        self.view.backgroundColor = backgroundColor
    }

    @IBAction func buttonAction(_ sender: Any) {
        buttonAction?()
    }
}

