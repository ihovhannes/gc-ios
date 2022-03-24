//
// Created by Hovhannes Sukiasian on 28/12/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation
import UIKit
import Look
import SnapKit
import RxCocoa
import RxSwift
import RxGesture
import GoogleMaps

class PartnerLocationsView: UIView, DisposeBagProvider {

    let markerTapped = PublishSubject<Int>()

    let SWITCHER_HEIGHT = 270

    let countText = UILabel()
    let switcherWidget = PartnerLocationsWidget.init()

    var currentIndex = 0

    let defaultMarkerFrame = CGRect(x: 0, y: 0, width: 40, height: 30)
    let selectedMarkerFrame = CGRect(x: 0, y: 0, width: 80, height: 60)
    var mapView: GMSMapView!
    fileprivate var mapMarkersData: [PartnerLocationsMarkerData] = []
    fileprivate var gmsMarkers: Array<WeakRef<GMSMarker>> = []

    override init(frame: CGRect) {
        super.init(frame: frame)

        let camera = GMSCameraPosition.camera(withLatitude: 56.0064, longitude: 92.926, zoom: 10)
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: camera)
        self.mapView.padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 0)
        mapView.delegate = self

        addSubview(mapView)
        addSubview(countText)
        addSubview(switcherWidget)

        countText.snp.makeConstraints { countText in
            countText.top.equalTo(16)
            countText.trailing.equalTo(-14)
        }

        switcherWidget.snp.makeConstraints { switcherWidget in
            switcherWidget.height.equalTo(SWITCHER_HEIGHT)
            switcherWidget.leading.equalToSuperview().offset(14)
            switcherWidget.trailing.equalToSuperview().offset(-14)
            switcherWidget.bottom.equalToSuperview().offset(-14)
        }

        mapView.snp.makeConstraints { mapView in
            mapView.edges.equalToSuperview()
        }

        mapView.look.apply(Style.mapView)
        look.apply(Style.partnerLocationsView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension PartnerLocationsView {

    func showIndex(index: Int) {
        guard index < mapMarkersData.count else {
            return
        }
        defer {
            currentIndex = index
        }

        let data = mapMarkersData[index]
        let position = CLLocationCoordinate2D(latitude: CLLocationDegrees(data.latitude), longitude: CLLocationDegrees(data.longitude))
        let update = GMSCameraUpdate.setTarget(position, zoom: 14)

        let currentMarker = gmsMarkers[currentIndex]
        currentMarker.value?.iconView?.frame = defaultMarkerFrame

        let marker = gmsMarkers[index]
        marker.value?.iconView?.frame = selectedMarkerFrame

        mapView.animate(with: update)
    }
}


extension PartnerLocationsView {

    func configureInit(pageColor: UIColor) {
        switcherWidget.backgroundColor = pageColor

        switcherWidget.isShown = false
        countText.isShown = false
    }

    func addSwitcherData(vendorsItems: [PartnerVendorItem]) {
        switcherWidget.isShown = true
        countText.isShown = true

        switcherWidget.transform = CGAffineTransform(translationX: 0, y: self.frame.height)
        countText.alpha = 0

        countText.text = "\(vendorsItems.count) " + "МАГАЗИНОВ\nНА КАРТЕ"

        UIView.animate(withDuration: 0.4, animations: { [unowned countText] () in
            countText.alpha = 1.0
        })

        if vendorsItems.count > 0 {
            switcherWidget.addVendors(vendors: vendorsItems)

            UIView.animate(withDuration: 0.4, animations: { [unowned switcherWidget, unowned self] () in
                switcherWidget.transform = CGAffineTransform.identity
                self.mapView.padding = UIEdgeInsets(top: 0, left: 10, bottom: CGFloat(self.SWITCHER_HEIGHT + 14 + 5), right: 0)
            })
        }
    }

}

extension PartnerLocationsView {

    func addVendorMarkers(markers: [PartnerLocationsMarkerData]) {
        self.mapMarkersData = markers

        for markerData in markers {
            let position = CLLocationCoordinate2D(latitude: CLLocationDegrees(markerData.latitude), longitude: CLLocationDegrees(markerData.longitude))
            let marker = GMSMarker(position: position)

            let imageMarker = UIImageView.init(frame: defaultMarkerFrame)
            imageMarker.contentMode = .scaleAspectFit
            marker.tracksViewChanges = true

            imageMarker.pin_setImage(from: URL(string: markerData.logoSrc)/*, completion: { [weak marker] _ in
                // We need change size by selection, so it should be always true
//                marker?.tracksViewChanges = false
            }*/)
            marker.iconView = imageMarker

            marker.map = mapView

            gmsMarkers.append(WeakRef(value: marker))
        }

        showIndex(index: 0)
    }

}

fileprivate extension Style {

    static var partnerLocationsView: Change<PartnerLocationsView> {
        return { (view: PartnerLocationsView) in
            view.backgroundColor = Palette.PartnerLocationsView.background.color

            view.countText.font = UIFont(name: "ProximaNova-Bold", size: 14)
            view.countText.textColor = Palette.PartnerLocationsView.countText.color
            view.countText.numberOfLines = 2
        }
    }


    static var mapView: Change<GMSMapView> {
        return { (view: GMSMapView) in
            do {
                // Set the map style by passing the URL of the local file.
                if let styleURL = Bundle.main.url(forResource: "style_map", withExtension: "json") {
                    view.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
                } else {
                    log("Unable to find style.json")
                }
            } catch {
                log("One or more of the map styles failed to load. \(error)")
            }
        }
    }

}

extension PartnerLocationsView: GMSMapViewDelegate {

    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        var indexOf = -1
        for (index, weakMarker) in gmsMarkers.enumerated() {
            if weakMarker.isEqual(with: marker) {
                indexOf = index
                break
            }
        }
        if indexOf >= 0 {
            markerTapped.on(.next(indexOf))
        }
        return false
    }

}
