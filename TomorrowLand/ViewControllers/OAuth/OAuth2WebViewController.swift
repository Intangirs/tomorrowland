//
//  OAuth2WebViewController.swift
//  TomorrowLand
//
//  Created by Yusuke Ohashi on 2018/09/23.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import UIKit
import WebKit
import Kiri
import Alamofire

class OAuth2WebViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    var hostName: String = ""
    var authCallBack: ((Bool, String?) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self

        var urlstring: String = "https://\(hostName)"
        urlstring += kOauthAuthorizePath
        urlstring += "?scope=" + Mastodon.shared.scope.urlEncoded()
        urlstring += "&client_id=" + Mastodon.shared.clientId
        urlstring += "&response_type=code"
        urlstring += "&redirect_uri=" + Mastodon.shared.redirectUri

        // Do any additional setup after loading the view.
        if let url = URL(string: urlstring) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }

}

extension OAuth2WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, url.path.contains(kOauthRedirectPath) {
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

                    Kiri<API>(request: .token(code)).send { (response, error) in
                        var result = false
                        do {
                            if let response = response {
                                let token: Token = try response.decodeJSON()
                                Mastodon.shared.token = token.access_token
                                result = true
                            }
                        } catch {
                            debugPrint(error)
                        }

                        DispatchQueue.main.async {
                            self.dismiss(animated: false, completion: {
                                self.authCallBack?(result, Mastodon.shared.token)
                            })
                        }
                        decisionHandler(.cancel)
                    }
                    return
                }
            }
        }
        decisionHandler(.allow)
    }
}
