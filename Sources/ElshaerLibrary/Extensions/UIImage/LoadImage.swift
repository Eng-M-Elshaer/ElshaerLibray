//
//  LoadImage.swift
//  ElshaerLibrary
//
//  Created by Restart iOS Technology on 08/12/2025.
//

#if !os(macOS)
import Kingfisher
#endif
#if canImport(UIKit)
import UIKit
#endif

#if canImport(UIKit) && !os(macOS)
extension UIImageView {
    func loadImageProfile(_ url: String?) {
        guard var linkString = url?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("[ImageLoader] loadImageProfile invalid URL string: nil")
            return
        }
        // Auto-upgrade HTTP -> HTTPS for ATS on our domain
        if var comps = URLComponents(string: linkString),
           comps.scheme?.lowercased() == "http",
           comps.host?.lowercased() == "breakfast.restart-technology.com" {
            comps.scheme = "https"
            if let upgraded = comps.string {
                print("[ImageLoader] loadImageProfile upgraded to HTTPS:", upgraded)
                linkString = upgraded
            } else {
                print("[ImageLoader] loadImageProfile failed to rebuild URL while upgrading to HTTPS:", linkString)
            }
        } else if let comps = URLComponents(string: linkString),
                  comps.scheme?.lowercased() == "http" {
            print("[ImageLoader] loadImageProfile insecure HTTP URL without ATS exception:", linkString)
        }
        guard let url = URL(string: linkString) else {
            print("[ImageLoader] loadImageProfile invalid URL after processing:", linkString)
            return
        }
        self.kf.indicatorType = .activity
        self.kf.setImage(
            with: url,
            placeholder: UIImage(),
            options: [
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ],
            completionHandler: { result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    var code: Int? = nil
                    if case let .responseError(reason) = error {
                        switch reason {
                        case .invalidHTTPStatusCode(let response):
                            code = response.statusCode
                        case .invalidURLResponse(let response):
                            code = (response as? HTTPURLResponse)?.statusCode
                        default:
                            break
                        }
                    }
                    print("[ImageLoader] loadImageProfile failed:", error.localizedDescription, "status:", code as Any, "url:", url.absoluteString)
                }
            }
        )
        ImageCache.default.diskStorage.config.expiration = .never
    }
    func loadImage(_ url: String?,
                   placeholder: UIImage =  UIImage() ,
                   isHasPlaceHolder: Bool = true) {
        guard var linkString = url?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("[ImageLoader] loadImage invalid URL string: nil")
            return
        }
        // Auto-upgrade HTTP -> HTTPS for ATS on our domain
        if var comps = URLComponents(string: linkString),
           comps.scheme?.lowercased() == "http",
           comps.host?.lowercased() == "breakfast.restart-technology.com" {
            comps.scheme = "https"
            if let upgraded = comps.string {
                print("[ImageLoader] loadImage upgraded to HTTPS:", upgraded)
                linkString = upgraded
            } else {
                print("[ImageLoader] loadImage failed to rebuild URL while upgrading to HTTPS:", linkString)
            }
        } else if let comps = URLComponents(string: linkString),
                  comps.scheme?.lowercased() == "http" {
            print("[ImageLoader] loadImage insecure HTTP URL without ATS exception:", linkString)
        }
        guard let url = URL(string: linkString) else {
            print("[ImageLoader] loadImage invalid URL after processing:", linkString)
            return
        }
        self.kf.indicatorType = .activity
        self.kf.setImage(
            with: url,
            placeholder: isHasPlaceHolder ? placeholder : nil,
            options: [
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ],
            completionHandler: { result in
                switch result {
                case .success:
                    break
                case .failure(let error):
                    var code: Int? = nil
                    if case let .responseError(reason) = error {
                        switch reason {
                        case .invalidHTTPStatusCode(let response):
                            code = response.statusCode
                        case .invalidURLResponse(let response):
                            code = (response as? HTTPURLResponse)?.statusCode
                        default:
                            break
                        }
                    }
                    print("[ImageLoader] loadImage failed:", error.localizedDescription, "status:", code as Any, "url:", url.absoluteString)
                }
            }
        )
        ImageCache.default.diskStorage.config.expiration = .never
    }
}
#endif // canImport(UIKit) && !os(macOS)
