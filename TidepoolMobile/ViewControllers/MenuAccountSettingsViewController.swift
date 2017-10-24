//
//  MenuAccountSettingsViewController.swift
//  TidepoolMobile
//
//  Created by Larry Kenyon on 9/14/15.
//  Copyright © 2015 Tidepool. All rights reserved.
//

import UIKit
import CocoaLumberjack

class MenuAccountSettingsViewController: UIViewController, UITextViewDelegate {

    var userSelectedSwitchProfile = false
    var userSelectedLogout = false
    var userSelectedLoggedInUser = false
    var userSelectedExternalLink: URL? = nil
    
    @IBOutlet weak var loginAccount: UILabel!
    @IBOutlet weak var versionString: TidepoolMobileUILabel!
    @IBOutlet weak var usernameLabel: TidepoolMobileUILabel!
    @IBOutlet weak var sidebarView: UIView!
    @IBOutlet weak var healthKitSwitch: UISwitch!
    @IBOutlet weak var healthKitLabel: TidepoolMobileUILabel!
    @IBOutlet weak var healthStatusContainerView: UIStackView!
    @IBOutlet weak var healthExplanation: UILabel!
    @IBOutlet weak var healthStatusLine1: UILabel!
    @IBOutlet weak var healthStatusLine2: UILabel!
    @IBOutlet weak var healthStatusLine3: UILabel!
    
    @IBOutlet weak var privacyTextField: UITextView!
    var hkTimeRefreshTimer: Timer?
    fileprivate let kHKTimeRefreshInterval: TimeInterval = 30.0

    //
    // MARK: - Base Methods
    //

    override func viewDidLoad() {
        super.viewDidLoad()
        let curService = APIConnector.connector().currentService!
        if curService == "Production" {
            versionString.text = "v" + UIApplication.appVersion()
        } else{
            versionString.text = "v" + UIApplication.appVersion() + " on " + curService
        }
        loginAccount.text = TidepoolMobileDataController.sharedInstance.currentUserName
        
        //healthKitSwitch.tintColor = Styles.brightBlueColor
        //healthKitSwitch.thumbTintColor = Styles.whiteColor
        healthKitSwitch.onTintColor = Styles.brightBlueColor

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(MenuAccountSettingsViewController.handleUploaderNotification(_:)), name: NSNotification.Name(rawValue: HealthKitNotifications.Updated), object: nil)
        notificationCenter.addObserver(self, selector: #selector(MenuAccountSettingsViewController.handleUploadSuccessfulNotification(_:)), name: NSNotification.Name(rawValue: HealthKitNotifications.UploadSuccessful), object: nil)
    }

    deinit {
        let nc = NotificationCenter.default
        nc.removeObserver(self, name: nil, object: nil)
        hkTimeRefreshTimer?.invalidate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        NSLog("MenuVC viewWillAppear")
        super.viewWillAppear(animated)
    }
    
    func menuWillOpen() {
        // Treat this like viewWillAppear...
        userSelectedLoggedInUser = false
        userSelectedSwitchProfile = false
        userSelectedLogout = false
        userSelectedExternalLink = nil

        usernameLabel.text = TidepoolMobileDataController.sharedInstance.userFullName
        configureHKInterface()

        // configure custom buttons
        sidebarView.setNeedsLayout()
        sidebarView.layoutIfNeeded()
        sidebarView.checkAdjustSubviewSizing()
    }
    
    //
    // MARK: - Navigation
    //

    @IBAction func done(_ segue: UIStoryboardSegue) {
        print("unwind segue to menuaccount done!")
    }

    //
    // MARK: - Button/switch handling
    //
    
    @IBAction func selectLoggedInUserButton(_ sender: Any) {
        userSelectedLoggedInUser = true
        self.hideSideMenuView()
    }
    
    @IBAction func switchProfileTapped(_ sender: AnyObject) {
        userSelectedSwitchProfile = true
        self.hideSideMenuView()
    }
    
    @IBAction func supportButtonHandler(_ sender: AnyObject) {
        APIConnector.connector().trackMetric("Clicked Tidepool Support (Hamburger)")
        userSelectedExternalLink = URL(string: TPConstants.kTidepoolSupportURL)
        self.hideSideMenuView()
    }
    
    @IBAction func privacyButtonTapped(_ sender: Any) {
        APIConnector.connector().trackMetric("Clicked Privacy and Terms (Hamburger)")
        userSelectedExternalLink = URL(string: "http://tidepool.org/legal/")
        self.hideSideMenuView()
    }
    
    @IBAction func logOutTapped(_ sender: AnyObject) {
        userSelectedLogout = true
        self.hideSideMenuView()
    }
    
    //
    // MARK: - Healthkit Methods
    //
    
    @IBAction func enableHealthData(_ sender: AnyObject) {
        if let enableSwitch = sender as? UISwitch {
            if enableSwitch == healthKitSwitch {
                if enableSwitch.isOn {
                    // Note: this enable function is asynchronous, so interface enable won't be true for a while
                    // TODO: rewrite to pass along completion routine?
                    enableHealthKitInterfaceForCurrentUser()
                    APIConnector.connector().trackMetric("Connect to health on")
                    // Note: because of above, avoid calling healthKitInterfaceEnabledForCurrentUser immediately...
                    configureHKInterfaceForState(true)
                } else {
                    TidepoolMobileDataController.sharedInstance.disableHealthKitInterface()
                    APIConnector.connector().trackMetric("Connect to health off")
                    configureHKInterfaceForState(false)
                }
            }
        }
    }

    fileprivate func startHKTimeRefreshTimer() {
        if hkTimeRefreshTimer == nil {
            hkTimeRefreshTimer = Timer.scheduledTimer(timeInterval: kHKTimeRefreshInterval, target: self, selector: #selector(MenuAccountSettingsViewController.nextHKTimeRefresh), userInfo: nil, repeats: true)
        }
    }

    func stopHKTimeRefreshTimer() {
        hkTimeRefreshTimer?.invalidate()
        hkTimeRefreshTimer = nil
    }

    func nextHKTimeRefresh() {
        //DDLogInfo("nextHKTimeRefresh")
        configureHKInterface()
    }

    internal func handleUploadSuccessfulNotification(_ notification: Notification) {
        DDLogInfo("handleUploadSuccessfulNotification: \(notification.name)")

        let earliestSampleTime = HealthKitBloodGlucoseUploadManager.sharedInstance.stats.lastSuccessfulUploadEarliestSampleTimeForCurrentPhase
        let latestSampleTime = HealthKitBloodGlucoseUploadManager.sharedInstance.stats.lastSuccessfulUploadLatestSampleTimeForCurrentPhase
        DDLogInfo("Successfully uploaded samples. Earliest sample date: \(earliestSampleTime), Latest sample date: \(latestSampleTime)")
    }
    
    internal func handleUploaderNotification(_ notification: Notification) {
        DDLogInfo("handleUploaderNotification: \(notification.name)")
        configureHKInterface()
    }

    private func configureHKInterface() {
        let hkCurrentEnable = appHealthKitConfiguration.healthKitInterfaceEnabledForCurrentUser()
        healthKitSwitch.isOn = hkCurrentEnable
        configureHKInterfaceForState(hkCurrentEnable)
    }
    
    // Note: this is used by the switch logic itself since the underlying interface enable lags asychronously behind the UI switch...
    private func configureHKInterfaceForState(_ hkCurrentEnable: Bool) {
        if hkCurrentEnable {
            self.configureHealthStatusLines()
            // make sure timer is turned on to prevent a stale interface...
            startHKTimeRefreshTimer()
        } else {
            stopHKTimeRefreshTimer()
        }
        
        let hideHealthKitUI = !appHealthKitConfiguration.shouldShowHealthKitUI()
        healthKitSwitch.isHidden = hideHealthKitUI
        healthKitLabel.isHidden = hideHealthKitUI
        healthStatusContainerView.isHidden = hideHealthKitUI || !hkCurrentEnable
        healthExplanation.isHidden = hideHealthKitUI || hkCurrentEnable
    }
    
    private func enableHealthKitInterfaceForCurrentUser() {
        if appHealthKitConfiguration.healthKitInterfaceConfiguredForOtherUser() {
            // use dialog to confirm delete with user!
            let curHKUserName = appHealthKitConfiguration.healthKitUserTidepoolUsername() ?? "Unknown"
            //let curUserName = usernameLabel.text!
            let titleString = "Are you sure?"
            let messageString = "A different account (" + curHKUserName + ") is currently associated with Health Data on this device"
            let alert = UIAlertController(title: titleString, message: messageString, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { Void in
                self.healthKitSwitch.isOn = false
                return
            }))
            alert.addAction(UIAlertAction(title: "Change Account", style: .default, handler: { Void in
                TidepoolMobileDataController.sharedInstance.enableHealthKitInterface()
            }))
            self.present(alert, animated: true, completion: nil)
        } else {
            TidepoolMobileDataController.sharedInstance.enableHealthKitInterface()
        }
    }
    
    let healthKitUploadStatusMostRecentSamples: String = "Uploading last 14 days of Dexcom data\u{2026}"
    let healthKitUploadStatusUploadPausesWhenPhoneIsLocked: String = "FYI upload pauses when phone is locked"
    let healthKitUploadStatusDaysUploaded: String = "%d of %d days"
    let healthKitUploadStatusUploadingCompleteHistory: String = "Uploading complete history of Dexcom data"
    let healthKitUploadStatusLastUploadTime: String = "Last reading %@"
    let healthKitUploadStatusNoDataAvailableToUpload: String = "No data available to upload"
    let healthKitUploadStatusDexcomDataDelayed3Hours: String = "Dexcom data from Health is delayed 3 hours"

    fileprivate func configureHealthStatusLines() {
        let uploadManager = HealthKitBloodGlucoseUploadManager.sharedInstance
        let phase = uploadManager.phase
        let stats = uploadManager.stats
        
        switch phase.currentPhase {
        case .mostRecent:
            healthStatusLine1.text = healthKitUploadStatusMostRecentSamples
            healthStatusLine2.text = healthKitUploadStatusUploadPausesWhenPhoneIsLocked
            healthStatusLine3.text = ""
        case .historical:
            healthStatusLine1.text = healthKitUploadStatusUploadingCompleteHistory
            var healthKitUploadStatusDaysUploadedText = ""
            if phase.totalDaysHistorical > 0 {
                healthKitUploadStatusDaysUploadedText = String(format: healthKitUploadStatusDaysUploaded, stats.currentDayHistorical, phase.totalDaysHistorical)
            }
            healthStatusLine2.text = healthKitUploadStatusDaysUploadedText
            healthStatusLine3.text = healthKitUploadStatusUploadPausesWhenPhoneIsLocked
        case .current:
            if uploadManager.stats.hasSuccessfullyUploaded {
                let lastUploadTimeAgoInWords = stats.lastSuccessfulUploadTime.timeAgoInWords(Date())
                healthStatusLine1.text = String(format: healthKitUploadStatusLastUploadTime, lastUploadTimeAgoInWords)
            } else {
                healthStatusLine1.text = healthKitUploadStatusNoDataAvailableToUpload
            }
            healthStatusLine2.text = healthKitUploadStatusDexcomDataDelayed3Hours
            healthStatusLine3.text = ""
        }
    }
    
    
}
