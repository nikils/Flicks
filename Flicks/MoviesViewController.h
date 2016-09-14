//
//  ViewController.h
//  yahooDemo
//
//  Created by Nikhil S on 9/12/16.
//  Copyright © 2016 Nikhil S. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MoviesViewController : UIViewController

@property (nonatomic, strong) NSString *endpoint;
@property (nonatomic, strong) UIRefreshControl *refreshControl;

@end

