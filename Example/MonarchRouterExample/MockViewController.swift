//
//  MockViewController.swift
//  MonarchRouterExample
//
//  Created by Eliah Snakin on 16/11/2018.
//  nikans.com
//

import UIKit
import MonarchRouter



/// Just a dummy UIViewController to test the Router.
class MockViewController: UIViewController
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    /// Call this method to configure VC right after the initialization or getting the `RouteParameters`.
    /// You can dispatch the route for this VC in `viewDidAppear(:)` for navigation consistency.
    func configure(title: String, buttonTitle: String?, buttonAction: (()->())?, backgroundColor: UIColor)
    {
        self.titleString = title
        self.buttonTitleString = buttonTitle
        self.buttonAction = buttonAction
        self.backgroundColor = backgroundColor
        
        applyConfig()
    }
    
    private var titleString: String!
    private var buttonTitleString: String?
    private var buttonAction: (()->())?
    private var backgroundColor: UIColor!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        didLoad = true
        applyConfig()
    }
    
    private var didLoad: Bool = false
    
    private func applyConfig() {
        guard didLoad else { return }
        
        self.titleLabel.text = titleString
        self.navigationItem.title = titleString
        
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


extension MockViewController: URIParametrizedPresentable
{
    func configure(with uriParameters: RouteURIParameters) {
        
    }
}
