//
//  ViewController.h
//  CascadeClassifierExample
//
//  Created by Michael Schneider on 8/19/16.
//  Copyright © 2016 Hive Brain, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/opencv.hpp>
#import <opencv2/videoio/cap_ios.h>
#import <opencv2/highgui.hpp>


@interface ViewController : UIViewController <CvVideoCameraDelegate>
{

    CvVideoCamera* videoCamera;
    cv::CascadeClassifier theClassifier;
    std::vector<cv::Rect> _faceRects;
}

@property (weak, nonatomic) IBOutlet UIImageView *theImageView;
@property (nonatomic, strong) CvVideoCamera* videoCamera;
@property (nonatomic) cv::CascadeClassifier theClassifier;


@end

