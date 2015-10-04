//
//  ViewController.swift
//  SwiftCamera
//
//  Created by haruhito on 2015/08/26.
//  Copyright (c) 2015年 FromF. All rights reserved.
//

import UIKit
import ImageIO

class ViewController: UIViewController , UINavigationControllerDelegate , UIImagePickerControllerDelegate {
    //UI
    @IBOutlet weak var imagePicture: UIImageView!
    
    ///撮影した写真
    var image : UIImage?
    ///保存対象の写真
    var saveImage : UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        image = UIImage(named: "Image")
        saveImage = image
        imagePicture.image = image
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:-Button Action
    @IBAction func doCamera(sender: AnyObject) {
        let alertController : UIAlertController = UIAlertController(title: "", message: "", preferredStyle: .ActionSheet)
        
        let cancelAction:UIAlertAction = UIAlertAction(title: "Cancel",
            style: UIAlertActionStyle.Cancel,
            handler:{
                (action:UIAlertAction!) -> Void in
        })
        
        let cameraAction:UIAlertAction = UIAlertAction(title: "Camera",
            style: UIAlertActionStyle.Default,
            handler:{
                (action:UIAlertAction!) -> Void in
                // カメラを起動する
                let ipc : UIImagePickerController = UIImagePickerController()
                ipc.sourceType = UIImagePickerControllerSourceType.Camera
                ipc.delegate = self
                self.presentViewController(ipc, animated: true, completion: nil)
        })
        let savedPhotosAlbumAction:UIAlertAction = UIAlertAction(title: "PhotoAlbum",
            style: UIAlertActionStyle.Default,
            handler:{
                (action:UIAlertAction!) -> Void in
                // フォトライブラリーを起動する
                let ipc : UIImagePickerController = UIImagePickerController()
                ipc.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
                ipc.delegate = self
                self.presentViewController(ipc, animated: true, completion: nil)
        })
        
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            alertController.addAction(cameraAction)
        }
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
            alertController.addAction(savedPhotosAlbumAction)
        }
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    @IBAction func doStamp(sender: AnyObject) {
        // 検出器生成
        let options:Dictionary = [CIDetectorAccuracy:CIDetectorAccuracyHigh]
        let detector:CIDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: options)
        
        // 検出
        let ciImage:CIImage = CIImage(CGImage: (image!.CGImage)!)
        let array = detector.featuresInImage(ciImage, options: nil)
        
        //context
        UIGraphicsBeginImageContext(image!.size)
        image!.drawInRect(CGRectMake(0,0,image!.size.width,image!.size.height))
        // 検出されたデータを取得
        for var i:Int = 0 ; i < array.count ; i++ {
            let faceFeature:CIFaceFeature = array[i] as! CIFaceFeature
            drawMeganeImage(faceFeature)
        }
        saveImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        imagePicture.image = saveImage
    }
    
    @IBAction func doEffect(sender: AnyObject) {
        let ciImage:CIImage = CIImage(CGImage: (image?.CGImage)!)
        let ciFilter:CIFilter = CIFilter(name: "CIPhotoEffectInstant")!
        ciFilter.setValue(ciImage, forKey: kCIInputImageKey)
        let ciContext:CIContext = CIContext(options: nil)
        let cgimg:CGImageRef = ciContext.createCGImage(ciFilter.outputImage!, fromRect:ciFilter.outputImage!.extent)
        
        saveImage = UIImage(CGImage: cgimg, scale: 1.0, orientation:UIImageOrientation.Up)
        imagePicture.image = saveImage
    }
    
    //MARK:-UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // 撮影画像を取得
        image = convertImage(info[UIImagePickerControllerOriginalImage] as! UIImage)
        imagePicture.image = image
        
        //写真のメターデータを取得
        //let metadata = info[UIImagePickerControllerMediaMetadata] as? NSDictionary
        
        // カメラUIを閉じる
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        // カメラUIを閉じる
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK:-DrawStamp
    func drawMeganeImage(faceFeature:CIFaceFeature) {
        if faceFeature.hasLeftEyePosition && faceFeature.hasRightEyePosition && faceFeature.hasMouthPosition {
            // 顔のサイズ情報を取得
            var faceRect:CGRect = faceFeature.bounds
            
            //上下座標が逆なので逆転させる
            faceRect.origin.y = image!.size.height - faceRect.origin.y - faceRect.size.height

            let kImage:UIImage? = UIImage(named: "kaeru")
            kImage?.drawInRect(faceRect)
        }
    }

    //MARK:-DrawStamp
    func convertImage(image:UIImage) -> UIImage
    {
        UIGraphicsBeginImageContext(image.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetInterpolationQuality(context, .High)
        image.drawInRect(CGRectMake(0, 0, image.size.width, image.size.height))
        let returnImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return returnImage
    }
    
    
    //SNSシェア系
    @IBAction func doSaveImage(sender: AnyObject) {
        //let activityViewContoller : UIActivityViewController = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        
        let activityViewContoller : UIActivityViewController = UIActivityViewController(activityItems:[saveImage!], applicationActivities: nil)
        
        self.presentViewController(activityViewContoller, animated: true, completion: nil)
    }
}

