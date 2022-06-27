//
//  ViewController.swift
//  AR_prac
//
//  Created by Joseph Ouyang on 2022/6/12.
//

import UIKit
import SceneKit
import ARKit

class ARViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate, ObservableObject {
    @IBOutlet weak var previewView: PreviewView!
    @IBOutlet weak var overlayView: OverlayView!
    @IBOutlet weak var resumeButton: UIButton!
    @IBOutlet weak var cameraUnavailableLabel: UILabel!
    
    @IBOutlet weak var bottomSheetStateImageView: UIImageView!
    @IBOutlet weak var bottomSheetView: UIView!
    @IBOutlet weak var bottomSheetViewBottomSpace: NSLayoutConstraint!
    
    // MARK: Constants
    private let displayFont = UIFont.systemFont(ofSize: 14.0, weight: .medium)
    private let edgeOffset: CGFloat = 2.0
    private let labelOffset: CGFloat = 10.0
    private let animationDuration = 0.5
    private let collapseTransitionThreshold: CGFloat = -10.0
    private let expandTransitionThreshold: CGFloat = 10.0
    private let delayBetweenInferencesMs: Double = 200
    
    // MARK: Instance Variables
    private var initialBottomSpace: CGFloat = 0.0
    var frameCount = 0
    
    // Holds the results at any time
    var result: Result?
    var grids = [Grid]()
    private let context = CIContext()
    private var previousInferenceTimeMs: TimeInterval = Date.distantPast.timeIntervalSince1970 * 1000
    
    // MARK: Controllers that manage functionality
    private var modelDataHandler: ModelDataHandler? =
    ModelDataHandler(modelFileInfo: MobileNetSSD.modelInfo, labelsFileInfo: MobileNetSSD.labelsInfo)
    var inferenceViewController: InferenceViewController?
    
    @Published var enableBattleSheet: Bool = false
    var onPokemonEnter: (Pokedex.PokemonInfo) -> Void = { pokemon in
        
    }
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard modelDataHandler != nil else {
            fatalError("Failed to load model")
        }
        overlayView.clearsContextBeforeDrawing = true
        overlayView.isUserInteractionEnabled = false
        
        addPanGesture()
        
        // Set the view's delegate
        sceneView.delegate = self
        sceneView.session.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        self.customInitialization()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    func presentUnableToResumeSessionAlert() {
        let alert = UIAlertController(
            title: "Unable to Resume Session",
            message: "There was an error while attempting to resume session.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    // MARK: Storyboard Segue Handlers
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if segue.identifier == "EMBED" {
            
            guard let tempModelDataHandler = modelDataHandler else {
                return
            }
            inferenceViewController = segue.destination as? InferenceViewController
            inferenceViewController?.wantedInputHeight = tempModelDataHandler.inputHeight
            inferenceViewController?.wantedInputWidth = tempModelDataHandler.inputWidth
            inferenceViewController?.threadCountLimit = tempModelDataHandler.threadCountLimit
            inferenceViewController?.currentThreadCount = tempModelDataHandler.threadCount
            inferenceViewController?.delegate = self
            
            guard let tempResult = result else {
                return
            }
            inferenceViewController?.inferenceTime = tempResult.inferenceTime
        }
    }
    
    // MARK: - ARSCNViewDelegate
    
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
        
        return node
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        self.resumeButton.isHidden = false
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
        self.cameraUnavailableLabel.isHidden = false
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
        
        // Updates UI once session interruption has ended.
        if !self.cameraUnavailableLabel.isHidden {
            self.cameraUnavailableLabel.isHidden = true
        }
        
        if !self.resumeButton.isHidden {
            self.resumeButton.isHidden = true
        }
    }
}

extension ARViewController {
    func presentVideoConfigurationErrorAlert() {
        let alertController = UIAlertController(title: "Configuration Failed", message: "Configuration of camera has failed.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func presentCameraPermissionsDeniedAlert() {
        let alertController = UIAlertController(title: "Camera Permissions Denied", message: "Camera permissions have been denied for this app. You can change this by going to Settings", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (action) in
            
            UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(settingsAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    /** This method runs the live camera pixelBuffer through tensorFlow to get the result.
     */
    @objc  func runModel(onPixelBuffer pixelBuffer: CVPixelBuffer) {
        // Run the live camera pixelBuffer through tensorFlow to get the result
        
        let currentTimeMs = Date().timeIntervalSince1970 * 1000
        
        guard  (currentTimeMs - previousInferenceTimeMs) >= delayBetweenInferencesMs else {
            return
        }
        
        previousInferenceTimeMs = currentTimeMs
        result = self.modelDataHandler?.runModel(onFrame: pixelBuffer)
        
        guard let displayResult = result else {
            return
        }
        
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        
        let capturedSize = CGSize(width: CGFloat(width), height: CGFloat(height))
        self.onReceiveResult(displayResult, capturedSize)
        
        DispatchQueue.main.async {
            
            // Display results by handing off to the InferenceViewController
            self.inferenceViewController?.resolution = CGSize(width: width, height: height)
            
            var inferenceTime: Double = 0
            if let resultInferenceTime = self.result?.inferenceTime {
                inferenceTime = resultInferenceTime
            }
            self.inferenceViewController?.inferenceTime = inferenceTime
            self.inferenceViewController?.tableView.reloadData()
            
            // Draws the bounding boxes and displays class names and confidence scores.
//            self.drawAfterPerformingCalculations(onInferences: displayResult.inferences, withImageSize: capturedSize)
        }
    }
    
    /**
     This method takes the results, translates the bounding box rects to the current view, draws the bounding boxes, classNames and confidence scores of inferences.
     */
    func drawAfterPerformingCalculations(onInferences inferences: [Inference], withImageSize imageSize:CGSize) {
        self.overlayView.objectOverlays = []
        self.overlayView.setNeedsDisplay()
        
        guard !inferences.isEmpty else {
            return
        }
        
        var objectOverlays: [ObjectOverlay] = []
        
        for inference in inferences {
            // Translates bounding box rect to current view.
            var convertedRect = inference.rect.applying(CGAffineTransform(scaleX: self.overlayView.bounds.size.width / imageSize.width, y: self.overlayView.bounds.size.height / imageSize.height))
            
            if convertedRect.origin.x < 0 {
                convertedRect.origin.x = self.edgeOffset
            }
            
            if convertedRect.origin.y < 0 {
                convertedRect.origin.y = self.edgeOffset
            }
            
            if convertedRect.maxY > self.overlayView.bounds.maxY {
                convertedRect.size.height = self.overlayView.bounds.maxY - convertedRect.origin.y - self.edgeOffset
            }
            
            if convertedRect.maxX > self.overlayView.bounds.maxX {
                convertedRect.size.width = self.overlayView.bounds.maxX - convertedRect.origin.x - self.edgeOffset
            }
            
            let confidenceValue = Int(inference.confidence * 100.0)
            let string = "\(inference.className)  (\(confidenceValue)%)"
            
            let size = string.size(usingFont: self.displayFont)
            
            let objectOverlay = ObjectOverlay(name: string, borderRect: convertedRect, nameStringSize: size, color: inference.displayColor, font: self.displayFont)
            
            objectOverlays.append(objectOverlay)
        }
        
        // Hands off drawing to the OverlayView
        self.draw(objectOverlays: objectOverlays)
    }
    
    /** Calls methods to update overlay view with detected bounding boxes and class names.
     */
    func draw(objectOverlays: [ObjectOverlay]) {
        self.overlayView.objectOverlays = objectOverlays
        self.overlayView.setNeedsDisplay()
    }
}

// MARK: InferenceViewControllerDelegate Methods
extension ARViewController: InferenceViewControllerDelegate {
    func didChangeThreadCount(to count: Int) {
        if modelDataHandler?.threadCount == count { return }
        modelDataHandler = ModelDataHandler(
            modelFileInfo: MobileNetSSD.modelInfo,
            labelsFileInfo: MobileNetSSD.labelsInfo,
            threadCount: count
        )
    }
    
}

// MARK: Bottom Sheet Interaction Methods
extension ARViewController {
    // MARK: Bottom Sheet Interaction Methods
    /**
     This method adds a pan gesture to make the bottom sheet interactive.
     */
    private func addPanGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(ViewController.didPan(panGesture:)))
        bottomSheetView.addGestureRecognizer(panGesture)
    }
    
    
    /** Change whether bottom sheet should be in expanded or collapsed state.
     */
    private func changeBottomViewState() {
        guard let inferenceVC = inferenceViewController else {
            return
        }
        
        if bottomSheetViewBottomSpace.constant == inferenceVC.collapsedHeight - bottomSheetView.bounds.size.height {
            
            bottomSheetViewBottomSpace.constant = 0.0
        }
        else {
            bottomSheetViewBottomSpace.constant = inferenceVC.collapsedHeight - bottomSheetView.bounds.size.height
        }
        setImageBasedOnBottomViewState()
    }
    
    /**
     Set image of the bottom sheet icon based on whether it is expanded or collapsed
     */
    private func setImageBasedOnBottomViewState() {
        if bottomSheetViewBottomSpace.constant == 0.0 {
            bottomSheetStateImageView.image = UIImage(named: "down_icon")
        }
        else {
            bottomSheetStateImageView.image = UIImage(named: "up_icon")
        }
    }
    
    /**
     This method responds to the user panning on the bottom sheet.
     */
    @objc func didPan(panGesture: UIPanGestureRecognizer) {
        // Opens or closes the bottom sheet based on the user's interaction with the bottom sheet.
        let translation = panGesture.translation(in: view)
        
        switch panGesture.state {
        case .began:
            initialBottomSpace = bottomSheetViewBottomSpace.constant
            translateBottomSheet(withVerticalTranslation: translation.y)
        case .changed:
            translateBottomSheet(withVerticalTranslation: translation.y)
        case .cancelled:
            setBottomSheetLayout(withBottomSpace: initialBottomSpace)
        case .ended:
            translateBottomSheetAtEndOfPan(withVerticalTranslation: translation.y)
            setImageBasedOnBottomViewState()
            initialBottomSpace = 0.0
        default:
            break
        }
    }
    
    /**
     This method sets bottom sheet translation while pan gesture state is continuously changing.
     */
    private func translateBottomSheet(withVerticalTranslation verticalTranslation: CGFloat) {
        
        let bottomSpace = initialBottomSpace - verticalTranslation
        guard bottomSpace <= 0.0 && bottomSpace >= inferenceViewController!.collapsedHeight - bottomSheetView.bounds.size.height else {
            return
        }
        setBottomSheetLayout(withBottomSpace: bottomSpace)
    }
    
    /**
     This method changes bottom sheet state to either fully expanded or closed at the end of pan.
     */
    private func translateBottomSheetAtEndOfPan(withVerticalTranslation verticalTranslation: CGFloat) {
        // Changes bottom sheet state to either fully open or closed at the end of pan.
        let bottomSpace = bottomSpaceAtEndOfPan(withVerticalTranslation: verticalTranslation)
        setBottomSheetLayout(withBottomSpace: bottomSpace)
    }
    
    /**
     Return the final state of the bottom sheet view (whether fully collapsed or expanded) that is to be retained.
     */
    private func bottomSpaceAtEndOfPan(withVerticalTranslation verticalTranslation: CGFloat) -> CGFloat {
        // Calculates whether to fully expand or collapse bottom sheet when pan gesture ends.
        var bottomSpace = initialBottomSpace - verticalTranslation
        
        var height: CGFloat = 0.0
        if initialBottomSpace == 0.0 {
            height = bottomSheetView.bounds.size.height
        }
        else {
            height = inferenceViewController!.collapsedHeight
        }
        
        let currentHeight = bottomSheetView.bounds.size.height + bottomSpace
        
        if currentHeight - height <= collapseTransitionThreshold {
            bottomSpace = inferenceViewController!.collapsedHeight - bottomSheetView.bounds.size.height
        }
        else if currentHeight - height >= expandTransitionThreshold {
            bottomSpace = 0.0
        }
        else {
            bottomSpace = initialBottomSpace
        }
        
        return bottomSpace
    }
    
    /**
     This method layouts the change of the bottom space of bottom sheet with respect to the view managed by this controller.
     */
    func setBottomSheetLayout(withBottomSpace bottomSpace: CGFloat) {
        view.setNeedsLayout()
        bottomSheetViewBottomSpace.constant = bottomSpace
        view.setNeedsLayout()
    }
}

extension ARViewController {
    func process_detection(_ session: ARSession, frame: ARFrame) {
        guard case .normal = frame.camera.trackingState else {
            return
        }
        
        if frameCount % 1 == 0 {
            self.run_model(session, frame: frame)
            frameCount = 0
        }
        frameCount += 1
    }
    
    func run_model(_ session: ARSession, frame: ARFrame) {
        guard let _ = modelDataHandler else {
            return
        }
        
        let pixelBuffer = frame.capturedImage
        guard let scaledPixelBuffer = CIImage(cvPixelBuffer: pixelBuffer)
            .oriented(.right)
            .toPixelBuffer(context: context)
        else {
            return
        }
        
        self.runModel(onPixelBuffer: scaledPixelBuffer)
    }
}
