//
//  AnnouncementsViewController.swift
//  MyNYUAD
//
//  Created by Tarlan Askaruly on 06.11.2021.
//  Copyright © 2021 Tony Morales. All rights reserved.
//

import UIKit
import WebKit

class AnnouncementsViewController: UIViewController {

  var wkWebView: WKWebView?
  var uiWebView: UIWebView?
  
  override func viewDidLoad() {
      super.viewDidLoad()
      let screenSize: CGRect = UIScreen.main.bounds
      let frameRect: CGRect = CGRect(x: 0, y: 0, width: screenSize.width, height: screenSize.height)
      let requestObj: URLRequest = URLRequest(url: URL(string: "http://10.225.71.95:3000")!);
      
      if ProcessInfo().isOperatingSystemAtLeast(OperatingSystemVersion(majorVersion: 8, minorVersion: 0, patchVersion: 0)) {
          self.wkWebView = WKWebView(frame: frameRect)
          self.wkWebView?.load(requestObj)
          self.view.addSubview(self.wkWebView!)
      } else {
          self.uiWebView = UIWebView(frame: frameRect)
          self.uiWebView?.loadRequest(requestObj)
          self.view.addSubview(self.uiWebView!)
      }

  }

  override func didReceiveMemoryWarning() {
      super.didReceiveMemoryWarning()
  }
  
}
