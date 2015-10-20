//
//  GameViewController.swift
//  CylinderChart
//
//  Created by Gabor Nagy on 10/19/15.
//  Copyright (c) 2015 Gabor Nagy. All rights reserved.
//

import UIKit
import QuartzCore
import SceneKit

class GameViewController: UIViewController {

    var xPosition: Float = 0.0
    let padding: Float = 0.5
    var chartNode: SCNNode = SCNNode()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create a new scene
        let scene = SCNScene()
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        scene.rootNode.addChildNode(cameraNode)
        
        cameraNode.camera?.usesOrthographicProjection = true
        cameraNode.camera?.orthographicScale = 10.0
        
        // place the camera
        cameraNode.position = SCNVector3(x: 12, y: 15, z: 30)
        cameraNode.rotation = SCNVector4(1, 0, 0, -M_PI / 8.0);
        
        // create and add a light to the scene
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light!.type = SCNLightTypeDirectional
        lightNode.light!.color = UIColor(white: 0.8, alpha: 1.0)
        lightNode.rotation = SCNVector4(0, 1, 0, -M_PI_4)
        scene.rootNode.addChildNode(lightNode)
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light!.type = SCNLightTypeAmbient
        ambientLightNode.light!.color = UIColor.darkGrayColor()
        scene.rootNode.addChildNode(ambientLightNode)
        
        let spotLightNode = SCNNode()
        spotLightNode.light = SCNLight()
        spotLightNode.light!.type = SCNLightTypeSpot
        spotLightNode.light!.color = UIColor(white: 0.5, alpha: 1.0)
        spotLightNode.position = SCNVector3(-30, 30, 30)
        spotLightNode.light!.castsShadow = true
        scene.rootNode.addChildNode(spotLightNode)
        
        // retrieve the SCNView
        let scnView = self.view as! SCNView
        
        // set the scene to the view
        scnView.scene = scene
        
        // allows the user to manipulate the camera
        scnView.allowsCameraControl = false
        
        // show statistics such as fps and timing information
        scnView.showsStatistics = false
        
        // configure the view
        scnView.backgroundColor = UIColor.whiteColor()
        
        // Make Floor
        let floor = SCNFloor()
        floor.firstMaterial?.emission.contents = UIColor.whiteColor()
        floor.reflectivity = 0.4
        floor.reflectionResolutionScaleFactor = 1.0
        floor.reflectionFalloffStart = 0
        floor.reflectionFalloffEnd = 5.0
        let floorNode = SCNNode(geometry: floor)
        floorNode.position.y = 0.0
        scene.rootNode.addChildNode(floorNode)

        scene.rootNode.addChildNode(chartNode)
        chartNode.position = SCNVector3(0.0, 0.0, 0.0)
        chartNode.rotation = SCNVector4(0.0, 1.0, 0.0, -M_PI/8.0)
        
        addCylinder(5.0, text: "Obj-C")
        addCylinder(9.0, text: "Swift")
        addCylinder(2.0, text: "Java")
        addCylinder(7.0, text: "Python")
        addCylinder(6.0, text: "C#")
        
        // Animate Torus
        //cameraNode.runAction(SCNAction.repeatActionForever(SCNAction.rotateByX(2, y: 0, z: 2, duration: 1)))
        
        //chartNode.runAction(SCNAction.rotateByX(0, y: 0.5, z: 0, duration: 10))

    }
    
    func addCylinder(barHeight: CGFloat, text: String) {
        let radius: CGFloat = 2.0
        let awesomeNess = Float(barHeight / 10.0)
        
        let green = float3(0.0, 0.7, 0.0)
        let red = float3(0.7, 0.0, 0.0)
        let ourColor = green * awesomeNess + red * (1.0 - awesomeNess)
        let color = UIColor(red: CGFloat(ourColor.x), green: CGFloat(ourColor.y), blue: CGFloat(ourColor.z), alpha: 1.0)
        
        let cylinder = SCNCylinder(radius: radius, height: barHeight)
        
        cylinder.firstMaterial?.diffuse.contents = color
        cylinder.firstMaterial?.specular.contents = UIColor.whiteColor()
        cylinder.firstMaterial?.shininess = 0.5
        
        let cylinderNode = SCNNode(geometry: cylinder)
        cylinderNode.position = SCNVector3(x: xPosition, y: Float(barHeight / 2.0), z: 0)
        chartNode.addChildNode(cylinderNode)

        let text = SCNText(string: text, extrusionDepth: 0.2)
        
        text.firstMaterial?.diffuse.contents = UIColor.darkGrayColor()
        text.firstMaterial?.specular.contents = UIColor.whiteColor()
        text.firstMaterial?.shininess = 0.5
        
        text.font = UIFont.systemFontOfSize(2.0)
        text.flatness = 0.01
        let textNode = SCNNode(geometry: text)
        var v1 = SCNVector3(x: 0,y: 0,z: 0)
        var v2 = SCNVector3(x: 0,y: 0,z: 0)
        text.getBoundingBoxMin(&v1, max: &v2)
        let dx = Float(v1.x - v2.x) / 2.0 + xPosition
        let dy = Float(barHeight) + padding + 1.0
        textNode.position = SCNVector3(x: dx, y: dy, z: 0.0)
        chartNode.addChildNode(textNode)
        
        xPosition += Float(radius * 3.0) + padding
        
        cylinderNode.addAnimation(growingCylinderAnimation(0.0), forKey: "grow")
    }
    
    func growingCylinderAnimation(delay: NSTimeInterval) -> CAAnimation {
        let grow = CABasicAnimation(keyPath: "geometry.height")
        grow.fromValue = 0.25
        let move = CABasicAnimation(keyPath: "position.y")
        move.fromValue = 0.25 / 2.0
        
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [grow, move]
        animationGroup.duration = 5.0
        animationGroup.beginTime = CACurrentMediaTime() + delay
        animationGroup.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        animationGroup.fillMode = kCAFillModeBackwards
        
        return animationGroup
    }
    
    func cylinderMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(red: 0.3, green: 0.5, blue: 1.0, alpha: 1.0)
        material.specular.contents = UIColor.whiteColor()
        material.shininess = 0.3
        material.locksAmbientWithDiffuse = true
        return material
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return UIInterfaceOrientationMask.Landscape
        } else {
            return .All
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

}
