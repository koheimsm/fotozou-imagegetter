//
//  ViewController.swift
//  fotozou-imagegetter
//
//  Created by Kohei Masumi on 2018/08/23.
//  Copyright © 2018年 Kohei Masumi. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController, UIScrollViewDelegate, UITextFieldDelegate {
    
    
    let sc = UIScrollView()
    var SearchBar = UITextField()
    var GoButton = UIButton()
    var DisplayImages: [UIImage] = []
    var photoUrlArray: [String] = []
    var ImageView = UIImageView()
    
    
    // APIのURL
    let baseUrl:String = "https://api.photozou.jp/rest"
    
    var searchKeyword = ""
    var limit_num = 1
    //let copyright = "&copyright=all"
    //let copyright_commercial = "&copyright_commercial=no"
    //let copyright_modifications = "&copyright_modification=no"
    //let offset  = "&offset=0"
    
    
    
    
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    func CGSizeMake(_ width: CGFloat, _ height: CGFloat)-> CGSize {
        return CGSize(width: width, height: height)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        sc.frame = self.view.frame
        sc.backgroundColor = UIColor.yellow
        sc.delegate = self
        sc.contentSize = CGSize(width: 375, height: 1000)
        view.addSubview(sc)
        self.view.sendSubview(toBack: sc)
        
        SearchBar.frame.size.width = self.view.frame.width * 2 / 3
        SearchBar.frame.size.height = 30
        SearchBar.center.x = self.view.center.x
        SearchBar.center.y = 109
        SearchBar.delegate = self;
        SearchBar.backgroundColor = UIColor.white
        SearchBar.layer.borderColor = UIColor.black.cgColor
        SearchBar.layer.borderWidth = 1
        SearchBar.placeholder = " キーワードを入力"
        SearchBar.clearButtonMode = .always
        sc.addSubview(SearchBar)
        self.view.bringSubview(toFront: SearchBar)
        
        GoButton.frame = CGRectMake(179, 147, 40, 25)
        GoButton.backgroundColor = UIColor.white
        //GoButton.layer.borderColor = UIColor.blue.cgColor
        //GoButton.layer.borderWidth = 1
        GoButton.setTitle("Go", for: .normal)
        GoButton.setTitleColor(UIColor.blue, for: .normal)
        GoButton.addTarget(self, action: #selector(ViewController.goButtonTapped(_:)), for: .touchDown)
        sc.addSubview(GoButton)
        self.view.bringSubview(toFront: GoButton)
        
        ImageView.frame.size.width = self.view.frame.width * 2 / 3
        ImageView.frame.size.height = 300
        ImageView.center.x = self.view.center.x
        ImageView.center.y = 400
        sc.addSubview(ImageView)
        self.view.bringSubview(toFront: ImageView)
        
        
    }
    
    @objc func goButtonTapped(_ seder: UIButton){
        
        if (SearchBar.text != nil){
            searchKeyword = SearchBar.text!
            print("searchKeyword:",searchKeyword)
            
            let keyword = "keyword=\(searchKeyword)"
            let limit = "limit=\(limit_num)"
            
            let apiString = "\(baseUrl)/search_public.json?\(keyword)&\(limit)"
            let encodedString = apiString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
            let encodeUrl: URL = URL(string: encodedString)!
            print("apiString:",apiString)
            print("encodeUrl:",encodeUrl)
            
            let request = URLRequest(url:encodeUrl)
            let task: URLSessionTask = URLSession.shared.dataTask(with: request, completionHandler: {data, response, error in
                
                
                
                if (error==nil){
                    // データ取得後の処理
                    print("data:",data!)
                    print("response:",response!)
                    
                    
                    struct Info: Codable {
                        let info: Photos
                        
                        struct Photos: Codable {
                            let NO_VIEW_FCEBOOK_TWITTER : Bool?
                            let CONTENTS_VIEW_LANG : Bool?
                            let photo_num: Int?
                            let photo: [Photo]
                            
                            struct Photo: Codable {
                                let photo_id: Int?
                                let user_id: Int?
                                let album_id: Int?
                                let photo_title: String?
                                let favorite_num: Int?
                                let comment_num: Int?
                                let view_num: Int?
                                let copyright: String?
                                let copyright_commercial: String?
                                let copyright_modifications: String?
                                let original_height: Int?
                                let original_width: Int?
                                //let geo: Geo
                                let date: String?
                                let regist_time: String?
                                let url: String?
                                let image_url: String?
                                let original_image_url: String?
                                let thumbnail_image_url: String?
                                let large_tag: String?
                                let medium_tag: String?
                                //struct Geo: Codable {
                                //let latitude: Int?
                                //let longitude: Int?
                                //}
                            }
                        }
                    }
                    print("data:",data!)
                    let dataStr: String? = String(data: data!, encoding: .utf8)
                    print("dataStr:",dataStr!)
                    
                    //デコード
                    do{
                        let decodedInfo = try JSONDecoder().decode(Info.self, from: data!)
                        //for i in 0..<self.limit_num {
                        
                        //original_image_urlの取得
                        let catPictureUrl = decodedInfo.info.photo.first?.original_image_url
                        self.photoUrlArray.append(catPictureUrl!)
                        
                        self.loadImage(urlString: catPictureUrl!)
                        
                        print("サムネイル:",catPictureUrl!)
                        //print("あい:",i)
                        //}
                    }catch{
                        print(error)
                    }
                    
                    print("サムネイルアレイ:",self.photoUrlArray)
                    
                    
                }else{
                    print("error:",error!)
                    return
                }
            })
            task.resume() //実行する
            
        }else{
            return
        }
    }
    //画像を非同期で読み込む(URLから変換)
    func loadImage(urlString: String){
        let CACHE_SEC : TimeInterval = 5 * 60; //5分キャッシュ
        let req = URLRequest(url: URL(string:urlString)!,
                             cachePolicy: .returnCacheDataElseLoad,
                             timeoutInterval: CACHE_SEC)
        let conf =  URLSessionConfiguration.default
        let session = URLSession(configuration: conf, delegate: nil, delegateQueue: OperationQueue.main)
        
        session.dataTask(with: req, completionHandler:
            { (data, resp, err) in
                if((err) == nil){ //Success
                    let image = UIImage(data:data!)
                    self.DisplayImages.append(image!)
                    self.ImageView.image = image!
                    
                }else{
                    print("ImageView:Error:",err!)
                }
        }).resume();
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}


