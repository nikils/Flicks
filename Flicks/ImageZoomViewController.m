//
//  ImageZoomViewController.m
//  yahooDemo
//
//  Created by Nikhil S on 9/13/16.
//  Copyright © 2016 Nikhil S. All rights reserved.
//

#import "ImageZoomViewController.h"
#import "UIImageView+AFNetworking.h"

@interface ImageZoomViewController () <UIScrollViewDelegate>

@end

@implementation ImageZoomViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.scrollView.delegate = self;
    self.scrollView.minimumZoomScale = 0.5;
    self.scrollView.maximumZoomScale = 2;
    self.scrollView.zoomScale = 0.5;
    [self loadImage:@"w154"];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapGesture.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tapGesture];

    UILabel *movieTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
    movieTitle.text = self.movie[@"title"];
    self.navigationItem.titleView = movieTitle;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadImage:(NSString*)imageSize {
    NSString *imageUrl = [NSString stringWithFormat:@"https://image.tmdb.org/t/p/w500%@", self.movie[@"poster_path"]];
    NSURLRequest *imgRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];
    [self.imageView setImageWithURLRequest:imgRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        self.imageView.image = image;
        self.scrollView.contentSize = image.size;
    } failure:nil];
    
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if (self.scrollView.zoomScale >= 1.5) {
        [self loadImage:@"w780"];
    } else if (self.scrollView.zoomScale >= 1.0) {
        [self loadImage:@"w500"];
    } else if (self.scrollView.zoomScale >= 0.6) {
        [self loadImage:@"w342"];
    }
}

- (void) handleTapGesture:(UITapGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        [self loadImage:@"w500"];
        self.scrollView.zoomScale = 1.0;
    }
}

@end
