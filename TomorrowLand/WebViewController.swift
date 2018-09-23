//
//  WebViewController.swift
//  TomorrowLand
//
//  Created by Yusuke Ohashi on 2018/09/23.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import UIKit
import WebKit
import Alamofire

class WebViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    var hostName: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self

        var urlstring: String = "https://\(hostName)"
        urlstring += Constants.oauthAuthorizePath
        urlstring += "?scope=" + Keys.MASTODON_SCOPE.urlEncoded()
        urlstring += "&client_id=" + Keys.MASTODON_CLIENT_ID
        urlstring += "&response_type=code"
        urlstring += "&redirect_uri=" + Keys.MASTODON_REDIRECT_URI
        
        // Do any additional setup after loading the view.
        if let url = URL(string: urlstring) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, url.path.contains(Constants.oauthRedirectPath) {
            if let query = url.query {
                let codequery = query.split(separator: "&").map { (pair) -> [String: String] in
                    let values = pair.split(separator: "=")
                    return [String(values[0]): String(values[1])]
                    }.first { (pair) -> Bool in
                        if let codekey = pair.keys.first {
                          return (codekey == "code")
                        }
                        return false
                }
                if let code = codequery?["code"] {
                    Alamofire.request("https://\(hostName)\(Constants.oauthTokenPath)",
                                      method: .post,
                                      parameters: [
                                        "code": code,
                                        "client_id": Keys.MASTODON_CLIENT_ID,
                                        "client_secret": Keys.MASTODON_CLIENT_SECRET,
                                        "redirect_uri": Keys.MASTODON_REDIRECT_URI,
                                        "grant_type": "authorization_code"],
                                      encoding: URLEncoding.httpBody,
                                      headers: nil)
                        .responseJSON { (response) in
                            debugPrint(response)
                    }
                    decisionHandler(.cancel)
                    return
                }
            }
        }
        decisionHandler(.allow)
    }
}
