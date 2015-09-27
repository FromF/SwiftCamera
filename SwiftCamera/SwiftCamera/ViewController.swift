//
//  ViewController.swift
//  SwiftCamera
//
//  Created by haruhito on 2015/08/26.
//  Copyright (c) 2015年 FromF. All rights reserved.
//

import UIKit

class ViewController: UIViewController , UINavigationControllerDelegate , UIImagePickerControllerDelegate {
    //UI
    @IBOutlet weak var imagePicture: UIImageView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //MARK:-Button Action
    @IBAction func doCamera(sender: AnyObject) {
        let sourceType:UIImagePickerControllerSourceType = UIImagePickerControllerSourceType.Camera
        
        // カメラやフォトライブラリが使用できなければ、何もせずに戻る
        if !UIImagePickerController.isSourceTypeAvailable(sourceType) {
            //NotSupport
            return
        }
        
        // カメラを起動する
        let ipc : UIImagePickerController = UIImagePickerController()
        ipc.sourceType = sourceType
        ipc.delegate = self
        self.presentViewController(ipc, animated: true, completion: nil)
    }
    
    @IBAction func doStamp(sender: AnyObject) {
        // 2枚目以降のときにカエル画像を消す
        for var i:Int = 0 ; i < imagePicture.subviews.count ; i++ {
            let view:AnyObject = imagePicture.subviews[i]
            view.removeFromSuperview()
        }
        
        // 検出器生成
        let options:Dictionary = [CIDetectorAccuracy:CIDetectorAccuracyHigh]
        let detector:CIDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: options)
        
        // 検出
        let ciImage:CIImage = CIImage(CGImage: imagePicture.image?.CGImage)
        let imageOptions:Dictionary = [CIDetectorImageOrientation : NSNumber(int: 6)]
        let array = detector.featuresInImage(ciImage, options: imageOptions)
        
        //context
        UIGraphicsBeginImageContext(imagePicture.image!.size)
        imagePicture.image!.drawInRect(CGRectMake(0,0,imagePicture.image!.size.width,imagePicture.image!.size.height))
        // 検出されたデータを取得
        for var i:Int = 0 ; i < array.count ; i++ {
            let faceFeature:CIFaceFeature = array[i] as! CIFaceFeature
            drawMeganeImage(faceFeature)
        }
        let drawedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        imagePicture.image = drawedImage
    }
    
    @IBAction func doEffect(sender: AnyObject) {
        let ciImage:CIImage = CIImage(CGImage: imagePicture.image?.CGImage)
        let ciFilter:CIFilter = CIFilter(name: "CIPhotoEffectInstant")
        ciFilter.setValue(ciImage, forKey: kCIInputImageKey)
        let ciContext:CIContext = CIContext(options: nil)
        let cgimg:CGImageRef = ciContext.createCGImage(ciFilter.outputImage, fromRect:ciFilter.outputImage.extent())
        
        imagePicture.image = UIImage(CGImage: cgimg, scale: 1.0, orientation:UIImageOrientation.Right)
    }
    
    //MARK:-UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        // 撮影画像を取得
        imagePicture.image = info[UIImagePickerControllerOriginalImage] as? UIImage
        
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
            let faceRect:CGRect = faceFeature.bounds
            
            // スタンプ画像と顔認識結果の幅高さの比率計算
            let widthScale:CGFloat = imagePicture.frame.size.width / imagePicture.image!.size.width
            let heightScale:CGFloat = imagePicture.frame.size.height / imagePicture.image!.size.height
            let scale:CGFloat = max(widthScale, heightScale)
            
            //スタンプ画像のサイズを求めるために顔認識結果から比率計算した後に上下方向のオフセット量を算出する
            let stampSize:CGSize = CGSizeMake(faceRect.size.width * scale, faceRect.size.height * scale)
            let stampOffset_x : CGFloat = (stampSize.width - faceRect.size.width) / 2
            let stampOffset_y : CGFloat = (stampSize.height - faceRect.size.height) / 2
            
            //スタンプ画像のRect
            var stampRect : CGRect = CGRectMake(faceRect.origin.x - stampOffset_x, faceRect.origin.y - stampOffset_y, faceRect.size.width * scale, faceRect.size.height * scale)

            //上下座標が逆なので逆転させる
            stampRect.origin.y = imagePicture.image!.size.height - stampRect.origin.y - stampRect.size.height

            let kImage:UIImage? = UIImage(named: "kaeru")
            kImage?.drawInRect(stampRect)
        }
    }

}

