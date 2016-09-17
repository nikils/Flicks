//
//  MovieDetailViewController.m
//  yahooDemo
//
//  Created by Nikhil S on 9/12/16.
//  Copyright © 2016 Nikhil S. All rights reserved.
//

#import "MovieDetailViewController.h"
#import "UIImageView+AFNetworking.h"

@interface MovieDetailViewController ()

@end

@implementation MovieDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = self.movie[@"title"];
    self.synopsisLabel.text = self.movie[@"overview"];
    self.dateLabel.text = self.movie[@"release_date"];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *releaseDate = [dateFormatter dateFromString:self.movie[@"release_date"]];
    
    [dateFormatter setDateFormat:@"MMMM dd, yyyy"];
    self.dateLabel.text = [dateFormatter stringFromDate:releaseDate];
    
    [self.popularityProgress setProgress:0 animated:NO];
    [self loadImage];
    [self loadMovie];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadImage {
    NSString *imageUrl = [NSString stringWithFormat:@"https://image.tmdb.org/t/p/w500%@", self.movie[@"poster_path"]];
    NSURLRequest *imgRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];
    [self.imageView setImageWithURLRequest:imgRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        self.imageView.image = image;
    } failure:nil];

}
- (void)loadMovie {
    NSString *apiKey = @"a07e22bc18f5cb106bfe4cc1f83ad8ed";
    NSString *urlString =
    [NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/%@?api_key=%@", self.movie[@"id"], apiKey];
    
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    
    NSURLSession *session =
    [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]
                                  delegate:nil
                             delegateQueue:[NSOperationQueue mainQueue]];
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
                                                if (!error) {
                                                    NSError *jsonError = nil;
                                                    NSDictionary *responseDictionary =
                                                    [NSJSONSerialization JSONObjectWithData:data
                                                                                    options:kNilOptions
                                                                                      error:&jsonError];
                                                    NSNumber *runtime = responseDictionary[@"runtime"];
                                                    NSNumber *popularity = responseDictionary[@"vote_average"];
                                                    
                                                    self.durationLabel.text = [self runtimeToString:runtime];
                                                    self.popularityLabel.text = [NSString stringWithFormat:@"%.f%%", popularity.floatValue*10];
                                                    [self.popularityProgress setProgress:(popularity.floatValue/10) animated:YES];
                                                    //NSLog(@"Response: %@", self.movies);
                                                } else {
                                                    NSLog(@"An error occurred: %@", error.description);
                                                }
                                            }];
    [task resume];
}

- (NSString *)runtimeToString:(NSNumber *)runtime {
    if (runtime.intValue > 60) {
        return [NSString stringWithFormat:@"%d hr %d mins", runtime.intValue/60, runtime.intValue%60];
    } else {
        return [NSString stringWithFormat:@"%d mins", runtime.intValue];
    }
}

@end
