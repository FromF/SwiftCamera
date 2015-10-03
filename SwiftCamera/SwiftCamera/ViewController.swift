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
    ///画像の向き
    var orientation : UIImageOrientation = .Up

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        image = UIImage(named: "Image")
        imagePicture.image = image
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
        // 検出器生成
        let options:Dictionary = [CIDetectorAccuracy:CIDetectorAccuracyHigh]
        let detector:CIDetector = CIDetector(ofType: CIDetectorTypeFace, context: nil, options: options)
        
        // 検出
        let ciImage:CIImage = CIImage(CGImage: (image!.CGImage)!)
        let imageOptions:Dictionary = [CIDetectorImageOrientation : NSNumber(int: 6)]
        let array = detector.featuresInImage(ciImage, options: imageOptions)
        
        //context
        UIGraphicsBeginImageContext(image!.size)
        image!.drawInRect(CGRectMake(0,0,image!.size.width,image!.size.height))
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
        let ciImage:CIImage = CIImage(CGImage: (image?.CGImage)!)
        let ciFilter:CIFilter = CIFilter(name: "CIPhotoEffectInstant")!
        ciFilter.setValue(ciImage, forKey: kCIInputImageKey)
        let ciContext:CIContext = CIContext(options: nil)
        let cgimg:CGImageRef = ciContext.createCGImage(ciFilter.outputImage!, fromRect:ciFilter.outputImage!.extent)
        
        imagePicture.image = UIImage(CGImage: cgimg, scale: 1.0, orientation:UIImageOrientation.Up)
    }
    
    //MARK:-UIImagePickerControllerDelegate
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // 撮影画像を取得
        image = convertImage(info[UIImagePickerControllerOriginalImage] as! UIImage)
        imagePicture.image = image
        
        //写真のメターデータを取得
        let metadata = info[UIImagePickerControllerMediaMetadata] as? NSDictionary
        
        // Exifの参照を取得
        //let exif = metadata?.objectForKey(kCGImagePropertyExifDictionary) as? NSDictionary
        
        // 画像の向きを取得
        /*
        *   1  =  0th row is at the top, and 0th column is on the left.
        *   2  =  0th row is at the top, and 0th column is on the right.
        *   3  =  0th row is at the bottom, and 0th column is on the right.
        *   4  =  0th row is at the bottom, and 0th column is on the left.
        *   5  =  0th row is on the left, and 0th column is the top.
        *   6  =  0th row is on the right, and 0th column is the top.
        *   7  =  0th row is on the right, and 0th column is the bottom.
        *   8  =  0th row is on the left, and 0th column is the bottom.
        */
        let exif_orientation:Int32 = (metadata?.objectForKey(kCGImagePropertyOrientation)?.intValue)!
        
        switch exif_orientation {
        case 1:
            orientation = .Left
        case 2:
            orientation = .Right
        case 3:
            orientation = .Right
        case 4:
            orientation = .Left
        case 5:
            orientation = .Up
        case 6:
            orientation = .Up
        case 7:
            orientation = .Down
        case 8:
            orientation = .Down
        default:
            orientation = .Up
        }

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
            stampRect.origin.y = image!.size.height - stampRect.origin.y - stampRect.size.height

            let kImage:UIImage? = UIImage(named: "kaeru")
            //kImage?.drawInRect(stampRect)
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
}

