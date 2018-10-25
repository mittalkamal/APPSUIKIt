//
//  APPSWebViewTableViewCell.swift
//  MRSA
//
//  Created by Ken Grigsby on 2/3/16.
//  Copyright © 2016 Wayne State University, Pharmacy & Medicine. All rights reserved.
//

import UIKit
import WebKit

@objc
protocol APPSWebViewTableViewCellDelegate: NSObjectProtocol
{
    // Notify the delegate the cell size has changed. The tableView should probably call
    // beginUpdate/endUpdate.
    @objc optional func webViewTableViewCellDidResizeWebView(_ cell: APPSWebViewTableViewCell)
}




open class APPSWebViewTableViewCell: UITableViewCell {
    
    weak var delegate: APPSWebViewTableViewCellDelegate?

    
    // MARK: - Outlets
    
    @IBOutlet weak var webViewContainer: UIView!
    @IBOutlet weak var webViewHeightConstraint: NSLayoutConstraint!
    var webView: WKWebView!
    
    typealias KVOContext = UInt8
    var MyObservationContext = KVOContext()

    
    // MARK: - Initialization

    deinit {
        webView.scrollView.removeObserver(self, forKeyPath: "contentSize")
        webView.stopLoading()
    }
    
    
    override open func awakeFromNib() {
        super.awakeFromNib()

        configureWebView()
        configureInitialState()
    }

    
    
    // MARK: - Lifecycle
   
    override open func prepareForReuse() {
        super.prepareForReuse()
        
        webView.stopLoading()
        configureInitialState()
    }
    
    
    override open func updateConstraints() {
        super.updateConstraints()
        
        if webView.scrollView.contentSize.height > 0 {
            webViewHeightConstraint.constant = webView.scrollView.contentSize.height
            delegate?.webViewTableViewCellDidResizeWebView?(self)
        }
    }
    
    
    func configureWebView() {
        
        webView = WKWebView(frame: webViewContainer.bounds)
        webView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        webViewContainer.addSubview(webView)

        let scrollView = webView.scrollView;
        scrollView.isScrollEnabled = false;
        scrollView.bounces = false;
        scrollView.showsHorizontalScrollIndicator = false;
        scrollView.showsVerticalScrollIndicator = false;

        // inherit color from webView container
        webView.backgroundColor = webViewContainer.backgroundColor
        webView.isOpaque = webViewContainer.isOpaque
       
        // Watch for the contentSize to change. This method was used instead of the webView delegate method,
        // didFinishNavigation, because the contentSize was zero at that time.
        scrollView.addObserver(self, forKeyPath: "contentSize", options: [], context: &MyObservationContext)
    }
    
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &MyObservationContext else { super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context); return }
        
        setNeedsUpdateConstraints()
    }
    
    
    func configureInitialState() {
        webViewHeightConstraint.constant = 1
    }
    
    
    
    // MARK: - Public API
    
    func loadHTMLString(_ string: String, baseURL: URL? = nil) {
        webView.loadHTMLString(string, baseURL: baseURL)
    }

    
    func stopLoading() {
        webView.stopLoading()
    }
}

