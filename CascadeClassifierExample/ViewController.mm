//
//  ViewController.m
//  CascadeClassifierExample
//
//  Created by Michael Schneider on 8/19/16.
//  Copyright © 2016 Hive Brain, Inc. All rights reserved.
//

#import "ViewController.h"





@implementation ViewController

@synthesize theClassifier, videoCamera;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
}

- (void)viewDidAppear:(BOOL)animated{
    
    [self loadClassifier];
    [self startCamera];
}



-(void)loadClassifier{
    
    NSString* pathToModel = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_default" ofType:@"xml"];
    const CFIndex CASCADE_NAME_LEN = 2048;
    char *CASCADE_NAME = (char *) malloc(CASCADE_NAME_LEN);
    CFStringGetFileSystemRepresentation( (CFStringRef)pathToModel, CASCADE_NAME, CASCADE_NAME_LEN);
    theClassifier.load(CASCADE_NAME);
    free(CASCADE_NAME);
}


-(void)startCamera {
    
    self.videoCamera = [[CvVideoCamera alloc] initWithParentView:self.theImageView];
    
    self.videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    self.videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
    self.videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    self.videoCamera.defaultFPS = 30;
    self.videoCamera.grayscaleMode = NO;
    self.videoCamera.delegate = self;
    [self.videoCamera start];
}



//This is the callback method that OpenCV calls with each frame from the camera as it captures video
- (void)processImage:(cv::Mat&)image {
    
    [self cascadeTest:image];
}


// Classify.

- (void)cascadeTest:(cv::Mat&)image {
    
    
    std::vector<cv::Rect> faceRects;
    
    double scalingFactor = 1.1;
    int minNeighbors = 20;
    int flags = 0;
    int theMinSize = 64;
    int theMaxSize = 480;
    
    cv::Size minimumSize(theMinSize,theMinSize);
    cv::Size maximumSize(theMaxSize,theMaxSize);
    
    theClassifier.detectMultiScale(image, faceRects, scalingFactor, minNeighbors, flags, minimumSize, maximumSize );
    
    for( std::vector<cv::Rect>::const_iterator r = faceRects.begin(); r != faceRects.end(); r++)
    {
        
        //This is one of the rectangles returned as a hit by the classifier.
        cv::Rect theHit(r->x,r->y,r->width,r->height);
        
        bool saveHits = false;  //Set to true to capture hits as files to sort and use for samples in training.

        if (saveHits)
        {
        cv::Mat HitMat = image(theHit);
        [self writeMatToFile:HitMat withFolderName:@"theHits"];
        }
        
        //Draw a rectangle around the hit on the image before sending it on to be displaed by the image view.
        cv::rectangle( image, cvPoint( r->x , r->y), cvPoint( r->x + r->width, r->y + r->height), cv::Scalar(0,255,0),3);
        
        
    }
    
}


-(void)writeMatToFile:(cv::Mat&)image withFolderName:(NSString*)theFolderName {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docs = [paths objectAtIndex:0];
    NSString *unclassFolderPath = [docs stringByAppendingPathComponent:theFolderName];
    [[[NSFileManager alloc] init] createDirectoryAtPath:unclassFolderPath withIntermediateDirectories: YES attributes:nil error:nil];
    NSTimeInterval theMark = [[NSDate date] timeIntervalSince1970];
    NSString *theFileName = [NSString stringWithFormat:@"%f.jpg",theMark];
    NSString *vocabPath = [unclassFolderPath stringByAppendingPathComponent:theFileName];
    cv::String FullPath = [vocabPath UTF8String];
    cv::imwrite(FullPath, image);
    
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}




@end
