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
        print("カメラボタンが押されたよ！")
        
        //アクションコントローラーを追加
        //(option)
        let alertController : UIAlertController = UIAlertController(title: "確認", message: "選択してください", preferredStyle: .ActionSheet)
        
        //キャンセルを押した場合
        let cancelAction:UIAlertAction = UIAlertAction(title: "キャンセル",
            //キャンセルはスタイルをCancelにする
            style: UIAlertActionStyle.Cancel,
            //アクションを書く
            handler:{
                (action:UIAlertAction!) -> Void in
                print("キャンセルが押されたよ！")
        })
        //カメラを押した場合
        let cameraAction:UIAlertAction = UIAlertAction(title: "カメラを選択する",
            style: UIAlertActionStyle.Default,
            //アクションを書く
            handler:{
                (action:UIAlertAction!) -> Void in
                // カメラを起動する
                //UIImagePickerControllerクラス
                //let 名前:型　= インスタンス生成(option)
                //初期設定　イニシャライザ
                let ipc : UIImagePickerController = UIImagePickerController()
                //インスタンス名.プロパティ名= 設定内容.Cameraにする
                //sourceTypeを設定する
                //UIImagePickerControllerSourceTypeで設定できる
                ipc.sourceType = UIImagePickerControllerSourceType.Camera
                ipc.delegate = self
                self.presentViewController(ipc, animated: true, completion: nil)
        })
        //フォトアルバムを押した場合
        let savedPhotosAlbumAction:UIAlertAction = UIAlertAction(title: "フォトアルバムを選択する",
            style: UIAlertActionStyle.Default,
            //アクションを書く
            handler:{
                (action:UIAlertAction!) -> Void in
                //フォトライブラリーから説明しよう！
                // フォトライブラリーを起動する
                //最初は、例外処理は無視して書きましょう
                let ipc : UIImagePickerController = UIImagePickerController()
                ipc.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
                //閉じる処理のときにdelegateが必要
                ipc.delegate = self
                //表示させる
                self.presentViewController(ipc, animated: true, completion: nil)
        })
        //カメラが起動できるかどうかを確認
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            //カメラが使用できる場合は、アラートに追加する
            alertController.addAction(cameraAction)
        }
        //フォトアルバムが使用できるか確認
        //アラートコントローラーを設定するときに、追加で書く
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.SavedPhotosAlbum) {
            //フォトアルバムが使用できる場合は、アラートに追加する
            alertController.addAction(savedPhotosAlbumAction)
        }
        //キャンセルのアクションをアラートに追加する
        alertController.addAction(cancelAction)
        //アラートコントローラーを表示する
        presentViewController(alertController, animated: true, completion: nil)
    }
    //写真加工
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
        //for分の説明が入る
        for var i:Int = 0 ; i < array.count ; i++ {
            //arrayの説明も必要？
            let faceFeature:CIFaceFeature = array[i] as! CIFaceFeature
            drawMeganeImage(faceFeature)
        }
        saveImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        imagePicture.image = saveImage
    }
    //エフェクトをかけてみよう
    //senderは自動で設定される
    //説明は必要？
    //AnyObject型　なんでも入る型
    //(sender: AnyObject)は引数
    //いろんなことが、自動で設定できるのがXcode
    //何回も変換する
    @IBAction func doEffect(sender: AnyObject) {
        //CIImageを生成
        let ciImage:CIImage = CIImage(CGImage: (image?.CGImage)!)
        //フィルターの名前を設定
        let ciFilter:CIFilter = CIFilter(name: "CIPhotoEffectInstant")!
         //ciImageをインプット画像にする
        ciFilter.setValue(ciImage, forKey: kCIInputImageKey)
        //CIContextに変換
        let ciContext:CIContext = CIContext(options: nil)
        //CGImageRefに変換
        let cgimg:CGImageRef = ciContext.createCGImage(ciFilter.outputImage!, fromRect:ciFilter.outputImage!.extent)
        //UIImageに変換
        saveImage = UIImage(CGImage: cgimg, scale: 1.0, orientation:UIImageOrientation.Up)
        //imageに渡す
        imagePicture.image = saveImage
    }
    
    //MARK:-UIImagePickerControllerDelegate
    //カメラ・フォトアルバムを終了したときに呼び出されるメソッド
    //引数にinfoが渡される
    //ここも最初に必要
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        // 撮影画像を取得
        image = convertImage(info[UIImagePickerControllerOriginalImage] as! UIImage)
        //画面に配置したimagePictureにimageを渡す
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
    //座標の変換
    func drawMeganeImage(faceFeature:CIFaceFeature) {
        if faceFeature.hasLeftEyePosition && faceFeature.hasRightEyePosition && faceFeature.hasMouthPosition {
            // 顔のサイズ情報を取得
            var faceRect:CGRect = faceFeature.bounds
            
            //上下座標が逆なので逆転させる
            //そういうもの・・・・？
            //他に使う場所はない。NextStepからきている
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
        //インスタンスを作成
        let activityViewContoller : UIActivityViewController = UIActivityViewController(activityItems:[saveImage!], applicationActivities: nil)
        //表示させる
        self.presentViewController(activityViewContoller, animated: true, completion: nil)
    }
}

