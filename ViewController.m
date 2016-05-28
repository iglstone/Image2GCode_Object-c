/*****************************************************************************
 *   ViewController.m
 ******************************************************************************
 *   by Kirill Kornyakov and Alexander Shishkov, 5th May 2013
 ******************************************************************************
 *   Chapter 3 of the "OpenCV for iOS" book
 *
 *   Linking OpenCV to iOS Project explains how to link OpenCV library
 *   and call any function from it.
 *
 *   Copyright Packt Publishing 2013.
 *   http://bit.ly/OpenCV_for_iOS_book
 *****************************************************************************/

#import "ViewController.h"
#import "opencv2/imgcodecs/ios.h"

#define POINTSCALE 3

@interface ViewController ()
{
    NSMutableArray *m_mutArray;
}
@end

@implementation ViewController

@synthesize imageView;

- (void)viewDidLoad
{
    [super viewDidLoad];
    m_mutArray = [NSMutableArray new];
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(480, 20, 100, 40)];
    btn.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:btn];
    [btn addTarget:self action:@selector(doneDraw) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitle:@"生成G代码" forState:UIControlStateNormal];
    
    NSString *pa = [self documentsPath:@"guolong2.gcode"];
    [[NSFileManager defaultManager] createFileAtPath:pa contents:nil attributes:nil];
    
    UIImage* image = [UIImage imageNamed:@"lena.png"];
//    UIImage* image = [UIImage imageNamed:@"bb.png"];
    
    
    UIImageToMat(image, cvImage);
    
    if (0)
    {
        
        NSString* filePath = [[NSBundle mainBundle]
                              pathForResource:@"lena" ofType:@"png"];
        // Create file handle
        NSFileHandle* handle = [NSFileHandle fileHandleForReadingAtPath:filePath];
        // Read content of the file
        NSData* data = [handle readDataToEndOfFile];
        // Decode image from the data buffer
        cvImage = cv::imdecode(cv::Mat(1, [data length], CV_8UC1,
                               (void*)data.bytes),
                               CV_LOAD_IMAGE_UNCHANGED);
    }
    
    if (0)
    {
        NSData* data = UIImagePNGRepresentation(image);
        // Decode image from the data buffer
        cvImage = cv::imdecode(cv::Mat(1, [data length], CV_8UC1,
                                       (void*)data.bytes),
                               CV_LOAD_IMAGE_UNCHANGED);
    }
    
    if (!cvImage.empty())
    {
        cv::Mat gray;
        cv::cvtColor(cvImage, gray, CV_RGB2GRAY);
        cv::GaussianBlur(gray, gray, cv::Size(5, 5), 1.5, 1.5);
        
        cv::Mat thresh;
        cv::threshold(gray, thresh, 190, 255, 0);
        
        UIImageView *newView = [UIImageView new];
        newView.frame = CGRectMake(30, 30, 320,480);
        [self.view addSubview:newView];
        newView.image = MatToUIImage(thresh);
        
        int row = thresh.rows; //480
        int clo = thresh.cols; //320
        
        cvFindContours(<#CvArr *image#>, <#CvMemStorage *storage#>, <#CvSeq **first_contour#>)
        
        //int m = thresh.channels();
        for (int i = 0 ; i < row; i = i+3) {
            NSString *tmp = @"";
            
            BOOL t1 = NO;
            BOOL t0 = NO;
            
            for (int j = 0; j < clo; j = j+2) { // in one line
//                int t =thresh.at<cv::Vec3b>(i,j)[0];
                int t =thresh.at<uchar>(i,j);
                
                tmp = [tmp stringByAppendingString:[NSString stringWithFormat:@" %d", t]];
                
                if (t == 255) {
                    if (t1 == NO) { //第一次碰到 1
                        
                        t1 = YES;//设置t1
                        [m_mutArray addObject: [self modeString:@"G0" x:j y:i]];
                        [m_mutArray addObject: @"G1 Z2.0\n"];
                        [m_mutArray addObject: [self modeString:@"G1" x:j y:i]];
                        
                    }else { //连续两点是 1
                        
                    }
                    t0 = NO; // 0点不连续
                } else {
                    if (t0 == NO) { //第一次是0
                        if (t1 == YES) { //连续两点是1，遇到第一个0点
                            [m_mutArray addObject: [self modeString:@"G1" x:j y:i]];
                            [m_mutArray addObject: @"G1 Z5\n"];
                            t1 = NO;// 1点不连续
                        }
                        t0 = YES;
                    } else { //第二次是还是0

                    }
                    t1 = NO;
                }
            }
            NSLog(@"%@", tmp);
        }
        /*
        for (int i = 0 ; i < row; i = i+1) {
            [m_mutArray addObject:@"G1 Z5.0\n"];
            [m_mutArray addObject:[self modeString:@"G0" x:i y:0]];
            BOOL conti = NO;
            BOOL tt = NO;
            for (int j = 0; j < clo; j = j+1) { // in one line
                int t =thresh.at<cv::Vec3b>(i,j)[0];
                if (t == 255) {
                    if (conti == NO) { //第一次碰到 1
                        
                        conti = YES;
                        [m_mutArray addObject: [self modeString:@"G0" x:i y:j]];
                        [m_mutArray addObject: @"G1 Z0.0\n"];

                    }else { //连续两点是 1
                        [m_mutArray addObject: [self modeString:@"G1" x:i y:j]];
                    }
                }else {
                    conti = NO;
                    if (tt == NO) {//第一次是0
                        tt = YES;
                        [m_mutArray addObject: @"G1 Z5\n"];
                    }else { //第二次是0
                        // noting
                    }
                }
            }
        }
        */
    }
    
    UIImageView *ann = [UIImageView new];
    ann.frame = CGRectMake(400, 400, 300, 360);
    [self.view addSubview:ann];
    ann.image = [UIImage imageNamed:@"aa"];
    
//    UIImageView *newView = [UIImageView new];
//    newView.frame = CGRectMake(30, 30, 96, 112);
//    [self.view addSubview:newView];
//    newView.image = MatToUIImage(cvImage);
    
    
    NSLog(@"ccc");
}

- (NSString *)modeString:(NSString *)mode x:(float)x y:(float)y {
    NSString *tmpString = [NSString stringWithFormat:@"%@ X%.02f Y%.02f\n", mode,(float)(x / POINTSCALE), (float)(y / POINTSCALE)];
    return tmpString;
}

- (void)doneDraw {
    NSString *pa = [self documentsPath:@"guolong2.gcode"];
    NSFileHandle *inFile = [NSFileHandle fileHandleForWritingAtPath:pa];
    NSString *final = @"G92 X0 Y0 Z2.0\nG21\nG90\nG1 F200.000000\nM05\n";
    [inFile truncateFileAtOffset:[inFile seekToEndOfFile]];
    [inFile writeData:[final dataUsingEncoding:NSUTF8StringEncoding]];
    for (NSString *st in m_mutArray) {
        [inFile truncateFileAtOffset:[inFile seekToEndOfFile]];
        [inFile writeData:[st dataUsingEncoding:NSUTF8StringEncoding]];
    }
    [inFile closeFile];
    NSLog(@"write done");
}

/*
- (void)doneDraw {
    NSString *final = @"G92 X0 Y0 Z2.0\nG21\nG90\nG1 F200.000000\nM05\n";
    for (NSString *st in m_mutArray) {
        final = [final stringByAppendingString:st];
    }
    final = [final stringByAppendingString:@"G0 X0.00 Y0.00\n"];
    BOOL re = [final writeToFile:[self documentsPath:@"guolong.gcode"] atomically:YES encoding:NSUTF8StringEncoding error:nil];
    if (re) {
        NSLog(@"write done");
    }else
        NSLog(@"write error");
    m_mutArray = nil;
}
*/

-(NSString *)documentsPath:(NSString *)fileName {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return [documentsDirectory stringByAppendingPathComponent:fileName];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
