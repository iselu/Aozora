//
//  InAppBrowserViewController.swift
//  Seedonk
//
//  Created by Larry Damman on 3/19/15.
//  Copyright (c) 2015 Seedonk. All rights reserved.
//

import WebKit

public class InAppBrowserViewController: UIViewController {

    var webView: WKWebView!

    public var initialUrl : NSURL? {
        didSet {
            if let initialUrl = initialUrl {
                lastRequest = NSURLRequest(URL: initialUrl)
            }
        }
    }

    var lastRequest : NSURLRequest?

    override public func viewDidLoad() {
        super.viewDidLoad()
        
        webView = WKWebView(frame: view.bounds)
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        navigationController?.navigationBar.barTintColor = UIColor.darkBlue()
        navigationController?.navigationBar.tintColor = UIColor.whiteColor()

        if let request = lastRequest {
            webView.loadRequest(request)
        }
    }

    @IBAction func dismissModal() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    deinit {
        webView = nil
    }

}


// MARK: <UIWebViewDelegate>

extension InAppBrowserViewController : WKNavigationDelegate {
    public func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
    }
    
}