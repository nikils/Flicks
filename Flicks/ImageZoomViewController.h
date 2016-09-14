//
//  ImageZoomViewController.h
//  yahooDemo
//
//  Created by Nikhil S on 9/13/16.
//  Copyright © 2016 Nikhil S. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageZoomViewController : UIViewController
@property (strong, nonatomic) NSDictionary *movie;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end
