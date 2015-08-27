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
        
        // 検出されたデータを取得
        for var i:Int = 0 ; i < array.count ; i++ {
            let faceFeature:CIFaceFeature = array[i] as! CIFaceFeature
            drawMeganeImage(faceFeature)
        }
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
            var faceRect:CGRect = faceFeature.bounds
            // 写真の向きで検出されたXとYを逆さにセット
            var temp:CGFloat = faceRect.size.width
            faceRect.size.width = faceRect.size.height
            faceRect.size.height = temp
            temp = faceRect.origin.x
            faceRect.origin.x = faceRect.origin.y
            faceRect.origin.y = temp
            
            // 比率計算
            let widthScale:CGFloat = imagePicture.frame.size.width / imagePicture.image!.size.width
            let heightScale:CGFloat = imagePicture.frame.size.height / imagePicture.image!.size.height
            let scale:CGFloat = min(widthScale, heightScale)
            
            // 画像のxとy、widthとheightのサイズを比率に合わせて変更
            faceRect.origin.x *= scale
            faceRect.origin.y *= scale
            faceRect.size.width *= scale
            faceRect.size.height *= scale
            
            // ImageViewの余白部分をオフセットさせる
            faceRect.origin.x += (imagePicture.frame.size.width - (imagePicture.image!.size.width * scale)) / 2
            faceRect.origin.y += (imagePicture.frame.size.height - (imagePicture.image!.size.height * scale)) / 2
            
            // 画像のxとyの位置を空白場所から画像の始点にオフセットする
            
            // UIImageViewを作成
            let kImage:UIImage = UIImage(named: "kaeru")!
            let kIMageView:UIImageView = UIImageView(image: kImage)
            kIMageView.contentMode = UIViewContentMode.ScaleAspectFit
            
            // 画像のリサイズ
            kIMageView.frame = faceRect
            
            // レイヤを撮影した写真に重ねる
            imagePicture.addSubview(kIMageView)
        }
    }

}

