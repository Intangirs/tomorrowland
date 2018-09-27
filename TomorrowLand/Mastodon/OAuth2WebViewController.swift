//
//  OAuth2WebViewController.swift
//  TomorrowLand
//
//  Created by Yusuke Ohashi on 2018/09/23.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import UIKit
import WebKit
import Alamofire

class OAuth2WebViewController: UIViewController {

    @IBOutlet weak var webView: WKWebView!
    var hostName: String = ""
    var authCallBack: ((Bool, String?) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self

        var urlstring: String = "https://\(hostName)"
        urlstring += Mastodon.Constants.oauthAuthorizePath
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

extension OAuth2WebViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url, url.path.contains(Mastodon.Constants.oauthRedirectPath) {
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
                    Alamofire.request("https://\(hostName)\(Mastodon.Constants.oauthTokenPath)",
                                      method: .post,
                                      parameters: [
                                        "code": code,
                                        "client_id": Keys.MASTODON_CLIENT_ID,
                                        "client_secret": Keys.MASTODON_CLIENT_SECRET,
                                        "redirect_uri": Keys.MASTODON_REDIRECT_URI,
                                        "grant_type": "authorization_code"],
                                      encoding: URLEncoding.httpBody,
                                      headers: nil)
                        .validate()
                        .responseJSON { (response) in
                            var success = false

                            switch response.result {
                            case .success(_):
                                do {
                                    //created the json decoder
                                    let decoder = JSONDecoder()
                                    //using the array to put values
                                    let token = try decoder.decode(Token.self, from: response.data ?? Data())
                                    if token.access_token.count > 0 {
                                        Mastodon.shared.token = token.access_token
                                        success = true
                                        self.authCallBack?(success, token.access_token)
                                    }
                                } catch {
                                    debugPrint(error)
                                }
                            case .failure(_):
                                break
                            }

                            DispatchQueue.main.async {
                                self.dismiss(animated: false, completion: nil)
                            }
                    }
                    decisionHandler(.cancel)
                    return
                }
            }
        }
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        dismiss(animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        dismiss(animated: true, completion: nil)
    }
}
