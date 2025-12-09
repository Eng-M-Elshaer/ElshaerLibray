//
//  UIViewController+Extensions.swift
//  ElshaerLibrary
//
//  Created by Restart iOS Technology on 08/12/2025.
//

import Foundation
#if canImport(UIKit)
import UIKit
import PDFKit
import MapKit
#endif

#if canImport(UIKit)
@MainActor
public final class PDFVC: UIViewController {
    
    var pdfURL: URL?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let pdfURL = pdfURL else { return }
        
        let pdfView = PDFView(frame: self.view.bounds)
        pdfView.autoScales = true
        pdfView.document = PDFDocument(url: pdfURL)
        
        view.addSubview(pdfView)
        
        let shareButton = UIButton(type: .system)
        shareButton.setImage(UIImage(systemName: SystemImageName.squareAndArrowUp), for: .normal)
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        shareButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(shareButton)
        
        NSLayoutConstraint.activate([
            shareButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            shareButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20)
        ])
    }
    
    @objc public func shareButtonTapped() {
        guard let pdfURL = pdfURL else { return }
        let activityViewController = UIActivityViewController(activityItems: [pdfURL], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view
        present(activityViewController, animated: true, completion: nil)
    }
}
#endif

#if canImport(UIKit)
@MainActor
public extension UIViewController {
    func getCurrentCellIndex(currentScrollOffset: CGFloat, collectionView: UICollectionView) -> Int {
        let inset: CGFloat = 6
        let indexPath = IndexPath(item: 0, section: 0)
        if let attr = collectionView.layoutAttributesForItem(at: indexPath) {
            let cellWidth = attr.bounds.width
            let centerCell = cellWidth / 2
            let result = Int((currentScrollOffset + centerCell) / (cellWidth + inset))
            return result
        }
        return 0
    }
    func removeLayerAtZPosition(view: UIView, zPosition: CGFloat = 888) {
        for subview in view.subviews {
            if subview.layer.zPosition == zPosition {
                subview.removeFromSuperview()
                break
            }
        }
    }
    func handleLayerAtZPosition(view: UIView, isHidden: Bool, zPosition: CGFloat = 888) {
        for subview in view.subviews {
            if subview.layer.zPosition == zPosition {
                subview.isHidden = isHidden
                break
            }
        }
    }
    func handleViewWithTag(view: UIView, isHidden: Bool, tag: Int = 777) {
        if let targetView = view.viewWithTag(tag) {
            targetView.isHidden = isHidden
        }
    }
}
#endif

#if canImport(UIKit)
@MainActor
public extension UIViewController {
    func openMapsWith(latitude: Double, longitude: Double, name: String) {
        let coordinates = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let placemark = MKPlacemark(coordinate: coordinates)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name

        let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]

        // Check if Google Maps is installed
        if let googleMapsURL = URL(string: "comgooglemaps://"), UIApplication.shared.canOpenURL(googleMapsURL) {
            // Provide option to choose between Apple Maps and Google Maps
            let alert = UIAlertController(title: "Choose Maps", message: "Selecta Maps App", preferredStyle: .actionSheet)

            // Open in Apple Maps
            let appleMapsAction = UIAlertAction(title: "Apple Maps", style: .default) { _ in
                mapItem.openInMaps(launchOptions: launchOptions)
            }
            alert.addAction(appleMapsAction)

            // Open in Google Maps
            let googleMapsAction = UIAlertAction(title: "Google Maps", style: .default) { _ in
                // Open in Google Maps
                if let url = URL(string: "comgooglemaps-x-callback://?saddr=&daddr=\(latitude),\(longitude)&directionsmode=driving") {
                    UIApplication.shared.open(url, options: [:])
                 }
            }
            alert.addAction(googleMapsAction)

            // Cancel action
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancelAction)

            // Present the action sheet
            self.present(alert, animated: true, completion: nil)
        } else {
            // If Google Maps is not installed, open in Apple Maps directly
            mapItem.openInMaps(launchOptions: launchOptions)
        }
    }
}
#endif
