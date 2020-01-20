//
//  MockViewController.swift
//  MonarchRouterExample
//
//  Created by Eliah Snakin on 16/11/2018.
//  nikans.com
//

import UIKit
import MonarchRouter



//class MockViewController: UIViewController
//{
//    @IBOutlet weak var titleLabel: UILabel!
//    @IBOutlet weak var button: UIButton!
//
//    /// Call this method to configure VC right after the initialization or getting the `RouteParameters`.
//    /// You can dispatch the route for this VC in `viewDidAppear(:)` for navigation consistency.
//    func configure(title: String, buttonTitle: String?, buttonAction: (()->())?, backgroundColor: UIColor)
//    {
//        self.titleString = title
//        self.buttonTitleString = buttonTitle
//        self.buttonAction = buttonAction
//        self.backgroundColor = backgroundColor
//
//        applyConfig()
//    }
//
//    private var titleString: String!
//    private var buttonTitleString: String?
//    private var buttonAction: (()->())?
//    private var backgroundColor: UIColor!
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        didLoad = true
//        applyConfig()
//    }
//
//    private var didLoad: Bool = false
//
//    private func applyConfig() {
//        guard didLoad else { return }
//
//        self.titleLabel.text = titleString
//        self.navigationItem.title = titleString
//
//        if let buttonTitle = buttonTitleString {
//            self.button.setTitle(buttonTitle, for: .normal)
//        }
//        button.isHidden = buttonTitleString == nil
//
//        self.view.backgroundColor = backgroundColor
//    }
//
//
//    @IBAction func buttonAction(_ sender: Any) {
//        buttonAction?()
//    }
//}
//
//
//extension MockViewController: RouteParametrizedPresentable
//{
//    func configure(with uriParameters: RouteParameters) {
//
//    }
//}



class MonarchViewController: UIViewController
{
    func configure(router: ProvidesRouteDispatch) {
        self.router = router
    }
    
    weak fileprivate var router: ProvidesRouteDispatch?
}




class LoginViewController: MonarchViewController
{
    @IBAction func buttonAction(_ sender: Any) {
        router?.dispatch(.onboarding(name: "Eliah"))
    }
}



class OnboardingViewController: MonarchViewController, RouteParametrizedPresentable
{
    struct RouteParametersModel {
        let title: String?
    }
    
    private var routeParameters: RouteParametersModel?
    
    func configure(routeParameters: RouteParameters) {
        self.routeParameters = RouteParametersModel(title: routeParameters.queryParameter("name"))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = "Hello, \(routeParameters?.title ?? "anonymous")"
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBAction func buttonAction(_ sender: Any) {
        router?.dispatch(.today)
    }
}



class TodayViewController: MonarchViewController
{
    @IBAction func story1ButtonAction(_ sender: Any) {
        router?.dispatch(.story(type: "news", id: 4269, title: "Story #1"))
    }
    
    @IBAction func story2ButtonAction(_ sender: Any) {
        router?.dispatch(.story(type: "ad", id: 1337, title: "Story #2"))
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        router?.dispatch(.allNews)
    }
}


class StoryViewController: MonarchViewController, RouteParametrizedPresentable
{
    func configure(routeParameters: RouteParameters) {
//        titleLabel.text = routeParameters.queryParameter("title")
            //+ uriParameters.pathParameter("type") + uriParameters.pathParameter("id")
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBAction func bookButtonAction(_ sender: Any) {
        router?.dispatch(.book(id: 8675, title: "Book #1"))
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        router?.dispatch(.today)
    }
}



class BooksViewController: MonarchViewController
{
    @IBAction func book1ButtonAction(_ sender: Any) {
        router?.dispatch(.book(id: 8675, title: "Book #1"))
    }
    
    @IBAction func book2ButtonAction(_ sender: Any) {
        router?.dispatch(.book(id: 2359, title: "Book #2"))
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        router?.dispatch(.deliveryInfo)
    }
}



class BookViewController: MonarchViewController, RouteParametrizedPresentable
{
    func configure(routeParameters: RouteParameters) {
//        titleLabel.text = routeParameters.queryParameter("title")
        //+ uriParameters.queryParameter("id")
    }
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBAction func storyButtonAction(_ sender: Any) {
        router?.dispatch(.story(type: "ad", id: 2340, title: "Story about a Book"))
    }
    
//    @IBAction func buttonAction(_ sender: Any) {
//        router?.dispatch(.today)
//    }
}


class ProfileViewController: MonarchViewController
{
    @IBAction func buttonAction(_ sender: Any) {
        router?.dispatch(.orders)
    }
}


class OrdersViewController: MonarchViewController
{
    @IBAction func book1ButtonAction(_ sender: Any) {
        router?.dispatch(.book(id: 8675, title: "Book #1"))
    }
    
    @IBAction func book2ButtonAction(_ sender: Any) {
        router?.dispatch(.book(id: 2359, title: "Book #2"))
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        router?.dispatch(.profile)
    }
}
