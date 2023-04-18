//
//  AccountVC.swift
//  Metastones
//
//  Created by Sonya Hew on 21/10/2019.
//  Copyright © 2019 Metagroup. All rights reserved.
//

import UIKit

enum eWalletCode: String {
    case metaPoint = "MP"
    case metaCoin = "MC"
}

enum AddressType {
    case billing
    case shipping
}

protocol AccountVCDelegate: class {
    func billingEdit(addrType: AddressType)
    func changePw()
    func personalInfoEdit()
}

class AccountVC: UIViewController {
    
    weak var delegate: MenuDelegate?
    weak var tabDelegate: SwitchTabDelegate?
    
    @IBOutlet weak var headerContainer: UIView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var ivHeader: UIImageView!
    @IBOutlet weak var navBarContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var btnMenu: UIButton!
    @IBOutlet weak var btnQr: UIButton!
    @IBOutlet weak var btnCart: UIButton!
    
    //cart indicator
    @IBOutlet weak var vwIndicator: UIView!
    @IBOutlet weak var lbIndicator: UILabel!
    
    let maxHeight = UIScreen.main.bounds.width*292/375
    let refresher = UIRefreshControl()
    
    let icons = [#imageLiteral(resourceName: "account-icon-my-order"), #imageLiteral(resourceName: "account-icon-my-transaction"), #imageLiteral(resourceName: "account-icon-my-transaction"), #imageLiteral(resourceName: "account-icon-wishlist"), #imageLiteral(resourceName: "account-icon-favourite"), #imageLiteral(resourceName: "account-icon-my-friends"), #imageLiteral(resourceName: "account-icon-setting")]
    let titles = [kLb.my_orders.localized, kLb.my_transaction.localized, kLb.my_withdrawal.localized, kLb.my_wishlists.localized, kLb.bazi_book_lists.localized, kLb.my_friends.localized, kLb.setting.localized]
    
    let appData = AppData.shared
    let viewModel = ViewModelBase()
    
    var walletDetail: [WalletDetailDataModel?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCartIndicator()
        setupTableView()
        navBarContainer.backgroundColor = UIColor.msBrown.withAlphaComponent(0)
        
        heightConstraint.constant = maxHeight
        ivHeader.heightAnchor.constraint(equalToConstant: maxHeight).isActive = true
        
        lbTitle.text = kLb.profile.localized.capitalized
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lbIndicator.text = "\(appData.data?.cartItemCount ?? 0)"
        setupWalletData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refresher.didMoveToSuperview()
    }
    
    func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0.1))
        tableView.sectionFooterHeight = 0.01
        tableView.sectionHeaderHeight = 0.01
        refresher.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        refresher.tintColor = .white
        tableView.addSubview(refresher)
    }
    
    func setupCartIndicator() {
        vwIndicator.applyCornerRadius(cornerRadius: vwIndicator.bounds.height/2)
    }
    
    @IBAction func menuHandler(_ sender: Any) {
        delegate?.showHideMenu()
    }
    
    @IBAction func cartHandler(_ sender: Any) {
        if isMemberUser(vc: self.navigationController) {
            navigationController?.pushViewController(getVC(sb: "Landing", vc: "MyCartVC"), animated: true)
        }
    }
    
    @IBAction func qrHandler(_ sender: Any) {
        navigationController?.pushViewController(getVC(sb: "Landing", vc: "NotificationVC"), animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.y        
        navBarContainer.backgroundColor = UIColor.msBrown.withAlphaComponent(offset/82)
        
        let newHeaderHeight = heightConstraint.constant - offset
        var headerImgTransform = CATransform3DIdentity
                
        if newHeaderHeight > maxHeight {
            heightConstraint.constant = maxHeight
            let scale = 1+abs(offset/100)
            headerImgTransform = CATransform3DScale(headerImgTransform, max(1, scale), max(1, scale), 1)
        }
        
        ivHeader.layer.transform = headerImgTransform
    }
    
    func setupWalletData() {
        viewModel.getWalletDetail(ewalletType: "") { (proceed, data) in
            if self.refresher.isRefreshing {
                self.refresher.endRefreshing()
            }
            
            if proceed {
                self.walletDetail = data?.data ?? []
            }
            
            self.tableView.reloadData()
        }
    }
    
    @objc func refreshData() {
        viewModel.getProfile { (proceed, data) in
            
            if proceed {
                self.setupWalletData()
            }
        }
    }
}

extension AccountVC: AccountVCDelegate {
    func billingEdit(addrType: AddressType) {
        let editVC = getVC(sb: "Profile", vc: "AddAddressVC") as! AddAddressVC
        editVC.editAddress = .edit
        if addrType == .billing {
            if let addrData = appData.profile?.addr.filter({$0?.defaultBilling == 1}).first {
                editVC.addrModel = addrData
            }
        } else {
            if let addrData = appData.profile?.addr.filter({$0?.defaultShipping == 1}).first {
                editVC.addrModel = addrData
                print(addrData!)
            }
        }
        navigationController?.pushViewController(editVC, animated: true)
    }
    
    func changePw() {
        navigationController?.pushViewController(getVC(sb: "Profile", vc: "ForgotPwVC"), animated: true)
    }
    
    func personalInfoEdit() {
        navigationController?.pushViewController(getVC(sb: "Profile", vc: "UpdateInfoVC"), animated: true)
    }
}

extension AccountVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 6 {
            return titles.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "profileWalletTVC") as! ProfileWalletTVC
            cell.selectionStyle = .none
            cell.profile = appData.profile?.profile
            cell.ivProfile.loadWithCache(strUrl: appData.profile?.profile?.avatar, placeholder: #imageLiteral(resourceName: "account-img-profile-defualt"))
            
            let metaPointData = walletDetail.filter({ $0?.ewalletTypeCode == eWalletCode.metaPoint.rawValue }).first
            let metaCoinData = walletDetail.filter({ $0?.ewalletTypeCode == eWalletCode.metaCoin.rawValue }).first
            cell.lbMetapoints.text  = kLb.meta_points.localized
            cell.lbMetapointsValue.text = metaPointData??.balance?.toDisplayCurrency() ?? ""
            cell.lbMetacoins.text = kLb.meta_coins.localized
            cell.lbMetacoinsValue.text = metaCoinData??.balance?.toDisplayCurrency() ?? ""
            cell.btnCam.isHidden = true
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "loginInfoTVC") as! LoginInfoTVC
            cell.selectionStyle = .none
            cell.delegate = self
            cell.lbMobileValue.text = appData.profile?.profile?.mobileNo
            cell.lbStatusValue.text = appData.profile?.profile?.memberType
            return cell
            
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "memberInfoTVC") as! MemberInfoTVC
            cell.selectionStyle = .none
            if let userId = appData.profile?.profile?.id {
                cell.lbmemberIdValue.text = "\(userId)"
            }
            cell.lbReferralValue.text = appData.profile?.profile?.replicatorName
            cell.shareUrl = appData.profile?.profile?.referralUrl
            return cell
            
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "personalInfoTVC") as! PersonalInfoTVC
            cell.selectionStyle = .none
            cell.delegate = self
            cell.lbFullnameValue.text = appData.profile?.profile?.fullName
            cell.lbDOBValue.text = appData.profile?.profile?.birthDate
            cell.lbEmailValue.text = appData.profile?.profile?.email
            cell.lbGenderValue.text = genders.filter({ $0.value == appData.profile?.profile?.gender }).first?.title.localized
            return cell
            
        case 4, 5:
            let cell = tableView.dequeueReusableCell(withIdentifier: "addressTVC") as! AddressTVC
            cell.tag = indexPath.section
            if let addr = appData.profile?.addr {
                if indexPath.section == 4 {
                    cell.setupIconAndTitle(withTitle: kLb.billing_address.localized.capitalized, icon: #imageLiteral(resourceName: "account-icon-billing.png"))
                    var defaultBillDisplayAddr = ""
                    
                    if let defaultBillingAddr = addr.filter({$0?.defaultBilling == 1}).first.map({($0?.address ?? "")}), defaultBillingAddr != "" {
                        defaultBillDisplayAddr = defaultBillingAddr
                        
                    } else {
                        defaultBillDisplayAddr = addr.first??.address ?? ""
                    }
                    
                    cell.lbAddress.text = defaultBillDisplayAddr
                    cell.addrType = .billing
                    
                } else {
                    cell.setupIconAndTitle(withTitle: kLb.delivery_address.localized.capitalized, icon: #imageLiteral(resourceName: "account-icon-delivery"))
                    var defaultShipDisplayAddr = ""
                    
                    if let defaultShipAddr = addr.filter({$0?.defaultShipping == 1}).first.map({($0?.address ?? "")}), defaultShipAddr != "" {
                        defaultShipDisplayAddr = defaultShipAddr
                        
                    } else {
                        defaultShipDisplayAddr = addr.first??.address ?? ""
                    }
                    
                    cell.lbAddress.text = defaultShipDisplayAddr
                    cell.addrType = .shipping
                }
            }
            
            cell.delegate = self
            cell.selectionStyle = .none
            return cell
            
        case 6:
            let cell = tableView.dequeueReusableCell(withIdentifier: "accountTVC") as! AccountTVC
            cell.setupIconAndTitle(withTitle: titles[indexPath.row].capitalized, icon: icons[indexPath.row])
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 4, 5:
            let addrVC = getVC(sb: "Profile", vc: "MyAddressesVC") as! MyAddressesVC
            if indexPath.section == 4 {
                addrVC.addressType = .billing
            } else {
                addrVC.addressType = .shipping
            }
            navigationController?.pushViewController(addrVC, animated: true)
        case 6:
            tableView.deselectRow(at: indexPath, animated: true)
            switch indexPath.row {
            case 0:
                navigationController?.pushViewController(getVC(sb: "Landing", vc: "MyOrderVC"), animated: true)
            case 1:
                navigationController?.pushViewController(getVC(sb: "Profile", vc: "TransactionsVC"), animated: true)
            case 2:
                navigationController?.pushViewController(getVC(sb: "Profile", vc: "MyWithdrawalVC"), animated: true)
            case 3:
                navigationController?.pushViewController(getVC(sb: "Profile", vc: "WishlistVC"), animated: true)
            case 4:
                navigationController?.pushViewController(getVC(sb: "Profile", vc: "FavouriteListVC"), animated: true)
            case 5:
                navigationController?.pushViewController(getVC(sb: "Profile", vc: "FriendsVC"), animated: true)
            case 6:
                navigationController?.pushViewController(getVC(sb: "Profile", vc: "SettingVC"), animated: true)
            default:
                print("error")
            }
        default:
            print("error")
        }
    }
}


//MARK:- ProfileWalletTVC
class ProfileWalletTVC: UITableViewCell {
    
    @IBOutlet weak var vwProfile: UIView!
    @IBOutlet weak var ivProfile: UIImageView!
    
    @IBOutlet weak var btnQr: UIButton!
    @IBOutlet weak var btnCam: UIButton!

    @IBOutlet weak var lbMetapoints: UILabel!
    @IBOutlet weak var lbMetapointsValue: UILabel!
    
    @IBOutlet weak var lbMetacoins: UILabel!
    @IBOutlet weak var lbMetacoinsValue: UILabel!
    
    @IBOutlet weak var btnReload: UIButton!
    
    @IBOutlet weak var vwCurve: UIView!
    
    let popupManager = PopupManager.shared
    var profile: ProfileDetailModel?
    
    override func awakeFromNib() {
        vwProfile.applyCornerRadius(cornerRadius: 56)
        vwProfile.addShadow(withRadius: 6, opacity: 0.3, color: UIColor.black.cgColor, offset: CGSize(width: 0, height: 3))
        
        ivProfile.contentMode = .scaleAspectFill
        ivProfile.applyCornerRadius(cornerRadius: 55)
        ivProfile.layer.borderColor = UIColor.white.cgColor
        ivProfile.layer.borderWidth = 5
                
        btnQr.addTargetClosure { (btn) in
            self.popupManager.showAlert(destVC: self.popupManager.getQRPopup(referralUrl: self.profile?.referralUrl ?? ""))
        }
        
        btnReload.addTargetClosure { (btn) in
            UIApplication.topViewController()?.navigationController?.pushViewController(getVC(sb: "Profile", vc: "WithdrawalVC"), animated: true)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
        vwCurve.roundCorners(corners: .allCorners, radius: UIScreen.main.bounds.width*2, withShadow: true)
    }
}

//MARK:- LoginInfoTVC
class LoginInfoTVC: UITableViewCell {
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var svContent: UIStackView!
    
    @IBOutlet weak var lbMobile: UILabel!
    @IBOutlet weak var lbMobileValue: UILabel!
    
    @IBOutlet weak var lbStatus: UILabel!
    @IBOutlet weak var lbStatusValue: UILabel!
    
    @IBOutlet weak var lbPassword: UILabel!
    @IBOutlet weak var lbPasswordValue: UILabel!
    
    @IBOutlet weak var btnChange: UIButton!
    @IBOutlet weak var lbChange: UILabel!
    
    weak var delegate: AccountVCDelegate?
    
    override func awakeFromNib() {
        lbTitle.text = kLb.login_info.localized.capitalized
        lbMobile.text = kLb.mobile.localized.capitalized
        lbStatus.text = kLb.status.localized.capitalized
        lbPassword.text = kLb.password.capitalized
        lbChange.text = kLb.change.localized.capitalized
        
        svContent.arrangedSubviews[2].isHidden = true
    }
    
    @IBAction func changePwHandler(_ sender: Any) {
        delegate?.changePw()
    }
}

//MARK:- MemberInfoTVC
class MemberInfoTVC: UITableViewCell {
    
    @IBOutlet weak var lbTitle: UILabel!
    
    @IBOutlet weak var lbMemberId: UILabel!
    @IBOutlet weak var lbmemberIdValue: UILabel!
    
    @IBOutlet weak var lbReferral: UILabel!
    @IBOutlet weak var lbReferralValue: UILabel!
    
    @IBOutlet weak var btnShare: BrownButton!
    
    var shareUrl: String? = ""
    
    override func awakeFromNib() {
        //btnShare.addShadow(withRadius: 8, opacity: 0.3, color: UIColor.black.cgColor, offset: CGSize(width: 0, height: 6))
        
        lbTitle.text = kLb.member_info.localized.capitalized
        lbMemberId.text = kLb.member_id.localized.capitalized
        lbReferral.text = kLb.referral.localized.capitalized
        btnShare.setTitle(kLb.share.localized.capitalized, for: .normal)
        btnShare.addTargetClosure { (btn) in
            UIApplication.topViewController()?.present(getShareActivity(shareItems: [self.shareUrl ?? ""], sourceView: self.btnShare), animated: true)
        }
    }
}

//MARK:- PersonalInfoTVC
class PersonalInfoTVC: UITableViewCell {
    
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbEdit: UILabel!
    
    @IBOutlet weak var lbFullname: UILabel!
    @IBOutlet weak var lbFullnameValue: UILabel!
    
    @IBOutlet weak var lbDOB: UILabel!
    @IBOutlet weak var lbDOBValue: UILabel!
    
    @IBOutlet weak var lbEmail: UILabel!
    @IBOutlet weak var lbEmailValue: UILabel!
    
    @IBOutlet weak var lbGender: UILabel!
    @IBOutlet weak var lbGenderValue: UILabel!
    
    weak var delegate: AccountVCDelegate?
    
    override func awakeFromNib() {
        lbTitle.text = kLb.personal_info.localized.capitalized
        lbEdit.text = kLb.edit.localized.capitalized
        lbFullname.text = kLb.full_name.localized.capitalized
        lbDOB.text = kLb.date_of_birth.localized.capitalized
        lbEmail.text = kLb.email.localized.capitalized
        lbGender.text = kLb.gender.localized.capitalized
    }
    
    @IBAction func editHandler(_ sender: Any) {
        delegate?.personalInfoEdit()
    }
}

//MARK:- AddressTVC
class AddressTVC: UITableViewCell {
    
    @IBOutlet weak var ivIcon: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var lbEdit: UILabel!
    
    @IBOutlet weak var lbAddress: UILabel!
    
    weak var delegate: AccountVCDelegate?
    var addrType: AddressType = .billing
    
    override func awakeFromNib() {
        lbEdit.text = kLb.edit.localized.capitalized
    }
    
    @IBAction func editHandler(_ sender: Any) {
        delegate?.billingEdit(addrType: addrType)
    }
    
    func setupIconAndTitle(withTitle title: String, icon: UIImage) {
        ivIcon.image = icon
        lbTitle.text = title.capitalized
    }
}

//MARK: - AccountTVC
class AccountTVC: UITableViewCell {
    
    @IBOutlet weak var ivIcon: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    
    override func awakeFromNib() {
        
    }
    
    func setupIconAndTitle(withTitle title: String, icon: UIImage) {
        ivIcon.image = icon
        lbTitle.text = title.capitalized
    }
}
