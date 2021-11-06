//
//  ViewController.swift
//  Tracked Images
//
//  Created by Tony Morales on 6/13/18.
//  Copyright © 2018 Tony Morales. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var blurView: UIVisualEffectView!
    
    fileprivate var alertStyle: UIAlertController.Style = .actionSheet
    
    let sleepyImage: UIImageView = {
        let imgView = UIImageView(image: UIImage(named: "art.scnassets/sleepy.jpeg"))
        return imgView
    }()
    
    let eventVideoPlayer: AVPlayer = {
        guard let url = Bundle.main.url(forResource: "event_video", withExtension: "mp4", subdirectory: "art.scnassets") else {
            print("Could not find video file")
            return AVPlayer()
        }
        
        return AVPlayer(url: url)
    }()
    
    let fluVideoPlayer: AVPlayer = {
        guard let url = Bundle.main.url(forResource: "flu_shot", withExtension: "mp4", subdirectory: "art.scnassets") else {
            print("Could not find video file")
            return AVPlayer()
        }
        
        return AVPlayer(url: url)
    }()
    
    let safetyVideoPlayer: AVPlayer = {
        guard let url = Bundle.main.url(forResource: "safety_training", withExtension: "mp4", subdirectory: "art.scnassets") else {
            print("Could not find video file")
            return AVPlayer()
        }
        
        return AVPlayer(url: url)
    }()
    
    lazy var statusViewController: StatusViewController = {
        return children.lazy.compactMap({ $0 as? StatusViewController }).first!
    }()
    
    let updateQueue = DispatchQueue(label: Bundle.main.bundleIdentifier! +
        ".serialSceneKitQueue")
    
    var session: ARSession {
        return sceneView.session
    }
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        statusViewController.restartExperienceHandler = { [unowned self] in
            self.restartExperience()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
        resetTracking()
        let configuration = ARImageTrackingConfiguration()

        guard let trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
          print("Could not load images")
          return
        }

        configuration.trackingImages = trackingImages
        configuration.maximumNumberOfTrackedImages = 4
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        session.pause()
    }
    
    var isRestartAvailable = true
    
    func resetTracking() {
        let configuration = ARImageTrackingConfiguration()
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    public func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        let alert = UIAlertController(style: self.alertStyle, title: "Simple Alert", message: "3 kinds of actions")
        
        if let imageAnchor = anchor as? ARImageAnchor {
            
            // Create a plane
            let plane = SCNPlane(width: imageAnchor.referenceImage.physicalSize.width, height: imageAnchor.referenceImage.physicalSize.height)
            
            if imageAnchor.referenceImage.name == "book" {
                let url = URL(string: "https://bobcat.library.nyu.edu/primo-explore/fulldisplay?docid=nyu_aleph007582767&context=L&vid=NYUAD&lang=en_US&search_scope=all&adaptor=Local%20Search%20Engine&isFrbr=true&tab=all&query=any,contains,the%20future%20we%20choose&sortby=date&facet=frbrgroupid,include,836504810&offset=0")!
                UIApplication.shared.openURL(url)
                resetScan()
            }
            
            if imageAnchor.referenceImage.name == "event_poster" {
                alert.addAction(title: "AR video", style: .default) { action in
                    plane.firstMaterial?.diffuse.contents = self.eventVideoPlayer
                    let planeNode = SCNNode(geometry: plane)
                    planeNode.eulerAngles.x = -.pi / 2
                    node.addChildNode(planeNode)
                    self.eventVideoPlayer.play()
                    self.eventVideoPlayer.volume = 0.4

                }
                alert.addAction(title: "Register", style: .default) { action in
                    let url = URL(string: "https://docs.google.com/forms/d/e/1FAIpQLScTtHgDQgh5I6jOI21nSpzlzbF76F4LL0ydnHWCX_HxNAMlJg/viewform")!
                    UIApplication.shared.openURL(url)
                    self.resetScan()
                }
                alert.addAction(title: "Cancel", style: .cancel) { action in
                    self.resetScan()
                }
                alert.show()
            }
            
            if imageAnchor.referenceImage.name == "dorm_student" {
                alert.addAction(title: "Live photo", style: .default) { action in
                    plane.firstMaterial?.diffuse.contents = self.sleepyImage
                    let planeNode = SCNNode(geometry: plane)
                    planeNode.eulerAngles.x = -.pi / 2
                    node.addChildNode(planeNode)
                }
                alert.addAction(title: "View Instagram", style: .default) { action in
                    let url = URL(string: "https://www.instagram.com/aural_sky/")!
                    UIApplication.shared.openURL(url)
                    self.resetScan()
                }
                alert.addAction(title: "Cancel", style: .cancel) { action in
                    self.resetScan()
                }
                alert.show()
            }
            
            if imageAnchor.referenceImage.name == "flu_poster" {
                alert.addAction(title: "AR video", style: .default) { action in
                    plane.firstMaterial?.diffuse.contents = self.fluVideoPlayer
                    let planeNode = SCNNode(geometry: plane)
                    planeNode.eulerAngles.x = -.pi / 2
                    self.fluVideoPlayer.play()
                    self.fluVideoPlayer.volume = 0.4
                    node.addChildNode(planeNode)
                }
                alert.addAction(title: "Watch on Youtube", style: .default) { action in
                    let url = URL(string: "https://www.youtube.com/watch?v=cIuGwaBFX8I")!
                    UIApplication.shared.openURL(url)
                    self.resetScan()
                }
                alert.addAction(title: "Read more", style: .default) { action in
                    self.session.pause()
                    let secondAlert = UIAlertController(style: .actionSheet)
                    secondAlert.addTextViewer(text: .attributedText(self.text))
                    secondAlert.addAction(title: "OK", style: .cancel) { action in
                        let configuration = ARImageTrackingConfiguration()
                        self.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
                        self.resetScan()
                    }
                    secondAlert.show()
                }
                alert.addAction(title: "Cancel", style: .cancel) { action in
                    self.resetScan()
                }
                alert.show()
            }
            
            if imageAnchor.referenceImage.name == "escape" {
                alert.addAction(title: "AR video", style: .default) { action in
                    plane.firstMaterial?.diffuse.contents = self.safetyVideoPlayer
                    let planeNode = SCNNode(geometry: plane)
                    planeNode.eulerAngles.x = -.pi / 2
                    self.safetyVideoPlayer.play()
                    self.safetyVideoPlayer.volume = 0.4
                    node.addChildNode(planeNode)
                }
                alert.addAction(title: "Watch on Youtube", style: .default) { action in
                    let url = URL(string: "https://www.youtube.com/watch?v=UuTowptYlrM")!
                    UIApplication.shared.openURL(url)
                    self.resetScan()
                }
                alert.addAction(title: "Cancel", style: .cancel) { action in
                    self.resetScan()
                }
                alert.show()
            }
            
            if imageAnchor.referenceImage.name == "wood" {
                self.session.pause()
                let secondAlert = UIAlertController(style: .actionSheet)
                secondAlert.addTextViewer(text: .attributedText(self.text2))
                secondAlert.addAction(title: "OK", style: .cancel) { action in
                    let configuration = ARImageTrackingConfiguration()
                    self.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
                    self.resetScan()
                }
                secondAlert.show()
            }
            
        }
        return node
    }
    
    private func resetScan() {
        self.resetTracking()
        let configuration = ARImageTrackingConfiguration()

        guard let trackingImages = ARReferenceImage.referenceImages(inGroupNamed: "AR Resources", bundle: nil) else {
            print("Could not load images")
            return
        }
        
        configuration.trackingImages = trackingImages
        configuration.maximumNumberOfTrackedImages = 4
        self.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    let text: [AttributedTextBlock] = [
                    .normal(""),
                    .header1("Flu Shots!!!"),
                    .header2("organized by Student Government"),
                    .normal("""
                        Everyone 6 months of age and older should get an influenza (flu) vaccine every season with rare exception. CDC’s Advisory Committee on Immunization Practices has made this recommendation since the 2010-2011 flu season.
                        Vaccination to prevent flu and its potentially serious complications is particularly important for people who are at higher risk of developing serious flu complications. See People at Higher Risk of Developing Flu-Related Complications for a full list of age and health factors that confer increased risk.
                        More information is available at Who Needs a Flu Vaccine.
                        Different influenza (flu) vaccines are approved for use in people in different age groups. In addition, some vaccines are not recommended for certain groups of people. Factors that can determine a person’s suitability for vaccination, or vaccination with a particular vaccine, include a person’s age, health (current and past) and any allergies to flu vaccine or its components. For more information, visit Who Should and Who Should NOT get a Flu Vaccine.
                        """)]
    
    let text2: [AttributedTextBlock] = [
        .normal(""),
        .header1("Wooden Tron!!!"),
        .header2("crafted by Katy Perry and Robert Pattinson"),
        .normal("""
            NYU Abu Dhabi (NYUAD) Art Gallery, the University’s academic museum-gallery, has opened its fall show, Speculative Landscapes. Curated by Executive Director of the NYUAD Art Gallery and the University’s Chief Curator, Maya Allison, this exhibition features four new installations by UAE-based artists. Each offers a distinct lens into the UAE and the region, and their work is gaining international recognition for its conceptual speculations on our contemporary world.
            
            Each installation in the exhibition can be experienced as both a physical and metaphorical landscape of the artist’s projected world. Working from observations of life in the UAE and beyond, these artists reflect back on our surroundings through: the lenses of risk (Kaoud), virtual reality (Jumairy), human-plant relations (Zedani), and the intersection of marketing with our metaphysical body (Khalid).
            """)
    ]
}


//let secondAlert = UIAlertController(style: .actionSheet)
//secondAlert.addTextViewer(text: .attributedText(self.text))
//secondAlert.addAction(title: "OK", style: .cancel)
//secondAlert.show()

//,
//.list("You have 14 calendar days to return an item from the date you received it."),
//.list("Only items that have been purchased directly from Apple, either online or at an Apple Retail Store, can be returned to Apple. Apple products purchased through other retailers must be returned in accordance with their respective returns and refunds policy."),
//.list("Please ensure that the item you're returning is repackaged with all the cords, adapters and documentation that were included when you received it."),
//.normal("There are some items, however, that are ineligible for return, including:"),
//.list("Opened software"),
//.list("Electronic Software Downloads"),
//.list("Software Up-to-Date Program Products (software upgrades)"),
//.list("Apple Store Gift Cards"),
//.list("Apple Developer products (membership, technical support incidents, WWDC tickets)"),
//.list("Apple Print Products"),
//.normal("*You can return software, provided that it has not been installed on any computer. Software that contains a printed software license may not be returned if the seal or sticker on the software media packaging is broken.")
//
//
