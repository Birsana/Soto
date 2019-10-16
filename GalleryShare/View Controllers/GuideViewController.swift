//
//  GuideViewController.swift
//  GalleryShare
//
//  Created by Andre Birsan on 2019-09-29.
//  Copyright © 2019 Andre Birsan. All rights reserved.
//

import UIKit

class GuideViewController: UIViewController {
    
    private let prevButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("PREV", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.systemPink, for: .normal)
        return button
    }()
    
    
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("NEXT", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.setTitleColor(.systemPink, for: .normal)
        
       // button.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        
        return button
    }()
    
 private let pageControl: UIPageControl = {
        let pc = UIPageControl()
        pc.currentPage = 0
        pc.numberOfPages = 4
        pc.currentPageIndicatorTintColor = .systemPink
        pc.pageIndicatorTintColor = UIColor(red: 249/255, green: 207/255, blue: 224/255,
                                            alpha: 1)
        return pc
    }()
    
    fileprivate func setupBottomControls(){
           let bottomControlsStackView = UIStackView(arrangedSubviews: [prevButton, pageControl, nextButton])
           bottomControlsStackView.translatesAutoresizingMaskIntoConstraints = false
           bottomControlsStackView.distribution = .fillEqually
           view.addSubview(bottomControlsStackView)
           
           NSLayoutConstraint.activate([
               bottomControlsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
               bottomControlsStackView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
               bottomControlsStackView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
               bottomControlsStackView.heightAnchor.constraint(equalToConstant: 50)
           ])
           
       }

    override func viewDidLoad() {
        super.viewDidLoad()


        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
