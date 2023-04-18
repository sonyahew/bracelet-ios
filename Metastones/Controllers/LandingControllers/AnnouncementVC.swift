//
//  AnnouncementVC.swift
//  Metastones
//
//  Created by Sonya Hew on 22/11/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

class AnnouncementVC: UIViewController {

    @IBOutlet weak var btnTopLeft: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var vwTop: UIView!
    
    let appData = AppData.shared
    
    weak var delegate: MenuDelegate?
    weak var tabDelegate: SwitchTabDelegate?
    
    var vcTitle: String = ""
    var desc : String = ""
    var isMenu: Bool = true
    var noData: Bool = true
    var displayData: DailyQuoteDataModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.applicationIconBadgeNumber = 0
        //appData.data?.quoteId
        ViewModelBase().getDailyQuote() { (proceed, data) in
            self.noData = data?.data == nil
            self.displayData = data?.data
            self.updateView()
        }
    }
    
    func updateView() {
        self.tableView.reloadData()
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.01))
        tableView.register(UINib(nibName: "EmptyDataTVC", bundle: Bundle.main), forCellReuseIdentifier: "emptyDataTVC")
    }
    
    @IBAction func menuHandler(_ sender: Any) {
//        if isMenu {
//            delegate?.showHideMenu()
//        } else {
//            self.dismiss(animated: true)
//        }
        self.dismiss(animated: true)
    }
}

extension AnnouncementVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if noData {
            let cell = tableView.dequeueReusableCell(withIdentifier: "emptyDataTVC") as! EmptyDataTVC
            cell.awakeFromNib()
            cell.selectionStyle = .none
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "announcementTVC") as! AnnouncementTVC
        cell.delegate = self
        cell.btnReadMore.isHidden = displayData?.url == nil || displayData?.url == ""
        
        cell.ivPoster.loadWithCache(strUrl: displayData?.imgPath)
        cell.ivPoster.contentMode = .scaleAspectFit
        cell.ivPoster.translatesAutoresizingMaskIntoConstraints = false
        cell.ivPoster.widthAnchor.constraint(equalToConstant: self.view.frame.size.width).isActive = true
        cell.ivPoster.loadWithCache(strUrl: displayData?.imgPath) { image in
            if let image = image {
                let ratio = image.size.width / self.view.frame.size.width
                cell.ivPoster.heightAnchor.constraint(equalToConstant: image.size.height / ratio).isActive = true
                tableView.reloadSections(IndexSet.init(integer: indexPath.section), with: .none)
            }
        }
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return noData ? UIScreen.main.bounds.width : UITableView.automaticDimension
    }
}

extension AnnouncementVC: AnnouncementTVCDelegate {
    func didReadMore() {
        self.dismiss(animated: true, completion: {
            deepLinkHandler(url: self.displayData?.url, navController: UIApplication.topViewController()?.navigationController)
        })
    }
}

//MARK:- AnnouncementTVC
protocol AnnouncementTVCDelegate: class {
    func didReadMore()
}
class AnnouncementTVC: UITableViewCell {
    
    @IBOutlet weak var ivPoster: UIImageView!
    @IBOutlet weak var btnReadMore: BrownButton!
    
    weak var delegate: AnnouncementTVCDelegate?
    
    override func awakeFromNib() {
        self.btnReadMore.isHidden = true
        btnReadMore.setTitle(kLb.read_more.localized, for: .normal)
    }
    
    @IBAction func readMoreHandler(_ sender: Any) {
        delegate?.didReadMore()
    }
    
    func hideImage() {
        ivPoster.heightAnchor.constraint(equalToConstant: 0.01).isActive = true
    }
}
