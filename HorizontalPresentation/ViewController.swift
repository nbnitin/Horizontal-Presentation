//
//  ViewController.swift
//  HorizontalPresentation
//
//  Created by Nitin Bhatia on 05/09/22.
//

import UIKit

class ViewController: UIViewController,UIScrollViewDelegate {
    
    //outlets
    @IBOutlet weak var presentationPageControl: UIPageControl!
    @IBOutlet weak var btnContinue: UIButton!
    @IBOutlet weak var presentationScrollView: UIScrollView!
    @IBOutlet weak var imgBackground: UIImageView!
    
    //variables
    // prepare slides
    var presentationSlides: [PresentationSlide] = []
    var slides: [Slide] = [
        
        Slide(title: "This is the best presentation ever!",
              subTitle: "This presentation is made of beautiful slides."),
        Slide(title: "When you slide, the background moves!",
              subTitle: "Isn't that the coolest thing ever?"),
        Slide(title: "The title shrinks as you slide away...",
              subTitle: "...and gets bigger as it slides in!"),
        Slide(title: "Follow the tutorial to see how it's done!",
              subTitle: "Don't worry, it's easier than you think."),
        Slide(title: "Press the button below...",
              subTitle: "...and make the magic happen!")
    ]
    var oldContentOffset : CGFloat = 0
    var currentScroll : Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // scroll view settings
        setUpScrollView()
        presentationScrollView.contentSize = CGSize(width: 0, height: 0)
        presentationScrollView.automaticallyAdjustsScrollIndicatorInsets = false
        presentationScrollView.alwaysBounceVertical = false
        presentationScrollView.alwaysBounceHorizontal = true
        presentationScrollView.isDirectionalLockEnabled = true
        
        btnContinue.layer.cornerRadius = btnContinue.frame.height / 2
        btnContinue.isUserInteractionEnabled = false
        btnContinue.alpha = 0
        
        // background image settings
        let viewHeight = view.frame.size.height
        let imageWidth = viewHeight * 1.4
        let padding: CGFloat = 10
        imgBackground.alpha = 0.5
        imgBackground.frame = CGRect(x: 0,
                                     y: -padding,
                                     width: imageWidth,
                                     height: viewHeight+padding*2)
        
        getSlides(completion: {res in
            self.setupSlideScrollView(slides: self.presentationSlides)
        })
        
        presentationPageControl.numberOfPages = getIntervals(pages: slides.count).count
        
        presentationScrollView.delegate = self
    }
    
    // create the slides
    func getSlides(completion: @escaping (Bool) -> ()) {
        
        for i in 0..<slides.count {
            // use the xib file created for the slide
            let slide: PresentationSlide = Bundle.main.loadNibNamed("PresentationSlide",
                                                                    owner: self,
                                                                    options: nil)?.first as! PresentationSlide
            // set up the labels
            slide.lblTitle.text = slides[i].title
            slide.lblSubTitle.text = slides[i].subTitle
            // add the created slide to the array
            self.presentationSlides.append(slide)
            // complete when all slides were added
            if presentationSlides.count == slides.count {
                completion(true)
            }
        }
    }
    
    // set up the scroll view
    func setupSlideScrollView(slides: [PresentationSlide]) {
        
        // set up the scroll view for its actual content (the screen + the rest of the slides)
        presentationScrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count),
                                                    height: view.frame.height)
        // enable paging so the user can only scroll through pages
        presentationScrollView.isPagingEnabled = true
        
        // set x position for each slide and add to scroll view
        for i in 0 ..< slides.count {
            presentationSlides[i].frame = CGRect(x: view.frame.width * CGFloat(i),
                                                 y: 0,
                                                 width: view.frame.width,
                                                 height: view.frame.height)
            presentationScrollView.addSubview(presentationSlides[i])
        }
        
    }
    
    // get the x position of each slide in the scroll view's width
    func getIntervals(pages: Int) -> [CGFloat] {
        
        var intervals: [CGFloat] = []
        // scroll view's left edge is 0, right edge is 1
        for i in stride(from: 0.0, through: 1.0, by: (1 / (Double(Float(pages)) - 1) )) {
            // multiply and divide by 100 to switch between Int and CGFloat
            intervals.append(CGFloat(i))
        }
        // return result as array
        return intervals
        
    }
    
    
    // set the scroll view's constraints
    func setUpScrollView() {
        // align the scroll view to the safe area
        presentationScrollView.translatesAutoresizingMaskIntoConstraints = false
        presentationScrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        presentationScrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        presentationScrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
        presentationScrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
    }
    
   
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        oldContentOffset = scrollView.contentOffset.x
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        
        if (self.oldContentOffset > scrollView.contentOffset.x) {
            // moved right if last content offset is greater then current offset
            
            if currentScroll < 0 {
                return
            }
            
            if presentationPageControl.currentPage == 0 {
                return
            }
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                self.imgBackground.frame.origin.x += 110
            }, completion: nil)
            currentScroll -= 1
        } else if (self.oldContentOffset < scrollView.contentOffset.x) {
            // moved left if last content offset is less that current offset
            
            if currentScroll >= slides.count - 1 {
                return
            }
            
            UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                self.imgBackground.frame.origin.x -= 110
            }, completion: nil)
            
            currentScroll += 1
            
        } else {
            // didn't move
        }
        
        
    }
    
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
            let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        presentationPageControl.currentPage = Int(pageIndex)
        
       
            
            let maximumHorizontalOffset: CGFloat = scrollView.contentSize.width - scrollView.frame.width
            let currentHorizontalOffset: CGFloat = scrollView.contentOffset.x
            
            // vertical
            let maximumVerticalOffset: CGFloat = scrollView.contentSize.height - scrollView.frame.height
            let currentVerticalOffset: CGFloat = scrollView.contentOffset.y
            
            let percentageHorizontalOffset: CGFloat = currentHorizontalOffset / maximumHorizontalOffset
            let percentageVerticalOffset: CGFloat = currentVerticalOffset / maximumVerticalOffset
            
            
            /*
             * below code changes the background color of view on paging the scrollview
             */
           //self.scrollView(scrollView, didScrollToPercentageOffset: percentageHorizontalOffset)
            
        
            /*
             * below code scales the imageview on paging the scrollview
             */
            let percentOffset: CGPoint = CGPoint(x: percentageHorizontalOffset, y: percentageVerticalOffset)
            
            if(percentOffset.x > 0 && percentOffset.x <= 0.25) {
                
                presentationSlides[0].lblTitle.transform = CGAffineTransform(scaleX: (0.25-percentOffset.x)/0.25, y: (0.25-percentOffset.x)/0.25)
                presentationSlides[1].lblTitle.transform = CGAffineTransform(scaleX: percentOffset.x/0.25, y: percentOffset.x/0.25)
                
            } else if(percentOffset.x > 0.25 && percentOffset.x <= 0.50) {
                presentationSlides[1].lblTitle.transform = CGAffineTransform(scaleX: (0.50-percentOffset.x)/0.25, y: (0.50-percentOffset.x)/0.25)
                presentationSlides[2].lblTitle.transform = CGAffineTransform(scaleX: percentOffset.x/0.50, y: percentOffset.x/0.50)
                
            } else if(percentOffset.x > 0.50 && percentOffset.x <= 0.75) {
                presentationSlides[2].lblTitle.transform = CGAffineTransform(scaleX: (0.75-percentOffset.x)/0.25, y: (0.75-percentOffset.x)/0.25)
                presentationSlides[3].lblTitle.transform = CGAffineTransform(scaleX: percentOffset.x/0.75, y: percentOffset.x/0.75)
                
            } else if(percentOffset.x > 0.75 && percentOffset.x <= 1) {
                presentationSlides[3].lblTitle.transform = CGAffineTransform(scaleX: (1-percentOffset.x)/0.25, y: (1-percentOffset.x)/0.25)
                presentationSlides[4].lblTitle.transform = CGAffineTransform(scaleX: percentOffset.x, y: percentOffset.x)
            }
        }
        
        
        
        
        func scrollView(_ scrollView: UIScrollView, didScrollToPercentageOffset percentageHorizontalOffset: CGFloat) {
            
            if presentationPageControl.currentPage == 0 {
                //Change background color to toRed: 103/255, fromGreen: 58/255, fromBlue: 183/255, fromAlpha: 1
                //Change pageControl selected color to toRed: 103/255, toGreen: 58/255, toBlue: 183/255, fromAlpha: 0.2
                //Change pageControl unselected color to toRed: 255/255, toGreen: 255/255, toBlue: 255/255, fromAlpha: 1
                
                let pageUnselectedColor: UIColor = fade(fromRed: 255/255, fromGreen: 255/255, fromBlue: 255/255, fromAlpha: 1, toRed: 103/255, toGreen: 58/255, toBlue: 183/255, toAlpha: 1, withPercentage: percentageHorizontalOffset * 3)
                presentationPageControl.pageIndicatorTintColor = pageUnselectedColor
            
                
                let bgColor: UIColor = fade(fromRed: 103/255, fromGreen: 58/255, fromBlue: 183/255, fromAlpha: 1, toRed: 255/255, toGreen: 255/255, toBlue: 255/255, toAlpha: 1, withPercentage: percentageHorizontalOffset * 3)
                presentationSlides[presentationPageControl.currentPage].backgroundColor = bgColor
                
                let pageSelectedColor: UIColor = fade(fromRed: 81/255, fromGreen: 36/255, fromBlue: 152/255, fromAlpha: 1, toRed: 103/255, toGreen: 58/255, toBlue: 183/255, toAlpha: 1, withPercentage: percentageHorizontalOffset * 3)
                presentationPageControl.currentPageIndicatorTintColor = pageSelectedColor
            }
        }
        
        
        func fade(fromRed: CGFloat,
                  fromGreen: CGFloat,
                  fromBlue: CGFloat,
                  fromAlpha: CGFloat,
                  toRed: CGFloat,
                  toGreen: CGFloat,
                  toBlue: CGFloat,
                  toAlpha: CGFloat,
                  withPercentage percentage: CGFloat) -> UIColor {
            
            let red: CGFloat = (toRed - fromRed) * percentage + fromRed
            let green: CGFloat = (toGreen - fromGreen) * percentage + fromGreen
            let blue: CGFloat = (toBlue - fromBlue) * percentage + fromBlue
            let alpha: CGFloat = (toAlpha - fromAlpha) * percentage + fromAlpha
            
            // return the fade colour
            return UIColor(red: red, green: green, blue: blue, alpha: alpha)
        }
}

