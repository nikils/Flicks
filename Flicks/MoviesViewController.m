//
//  ViewController.m
//  yahooDemo
//
//  Created by Nikhil S on 9/12/16.
//  Copyright © 2016 Nikhil S. All rights reserved.
//

#import "MoviesViewController.h"
#import "MovieCellTableViewCell.h"
#import "MovieCollectionViewCell.h"
#import "UIImageView+AFNetworking.h"
#import "MovieDetailViewController.h"
#import "ImageZoomViewController.h"

@interface MoviesViewController () <UITableViewDelegate, UITableViewDataSource, UICollectionViewDataSource, UICollectionViewDelegate, UIScrollViewDelegate, UISearchBarDelegate>
@property (strong, nonatomic) NSNumber *currentPage;
@property (strong, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) NSNumber *totalPage;
@property (nonatomic) BOOL callInProgress;
@property (nonatomic) BOOL isGrid;
@property (strong, nonatomic) NSArray *allMovies;
@property (strong, nonatomic) NSArray *movies;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *errorView;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UIView *loadingView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicatorView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentControl;
-(void)loadMovies:(NSString *)searchText;
@end

@implementation MoviesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.refreshControl = [[UIRefreshControl alloc] initWithFrame:self.refreshControl.bounds];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView addSubview:self.refreshControl];
    [self.refreshControl addTarget:self action:@selector(loadMovies) forControlEvents:UIControlEventValueChanged];
    self.loadingView.layer.cornerRadius = 10.0;
    self.loadingView.hidden = YES;
    self.tableView.contentInset = UIEdgeInsetsMake(0, -1, 0, 0);
    self.isGrid = NO;
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.currentPage = @(1);
    self.searchBar = [[UISearchBar alloc] init];
    self.searchBar.delegate = self;
    self.navigationItem.titleView = self.searchBar;
    [self loadMovies:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.errorView.hidden == NO) {
        [self loadMovies:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadMovies:(NSString *)searchText {
    if (self.callInProgress) {
        return;
    }
    self.callInProgress = TRUE;
    self.loadingView.hidden = NO;
    NSString *apiKey = @"a07e22bc18f5cb106bfe4cc1f83ad8ed";
    NSString *urlString =
    [NSString stringWithFormat:@"https://api.themoviedb.org/3/movie/%@?api_key=%@&page=%@", self.endpoint, apiKey, self.currentPage];
    if (searchText) {
        urlString =
        [NSString stringWithFormat:@"https://api.themoviedb.org/3/search/movie?api_key=%@&query=%@", apiKey, searchText];
    }
    self.errorView.hidden = YES;
    self.errorLabel.text = @"";
    
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
                                                self.callInProgress = FALSE;
                                                self.loadingView.hidden = YES;
                                                if (!error) {
                                                    NSError *jsonError = nil;
                                                    NSDictionary *responseDictionary =
                                                    [NSJSONSerialization JSONObjectWithData:data
                                                                                    options:kNilOptions
                                                                                      error:&jsonError];
                                                    if (searchText || !self.movies) {
                                                        self.movies = responseDictionary[@"results"];
                                                    } else {
                                                        self.movies = [self.movies arrayByAddingObjectsFromArray:responseDictionary[@"results"]];
                                                    }
                                                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K contains %@", @"poster_path", @"/"];
                                                    self.movies =  [self.movies filteredArrayUsingPredicate:predicate];
                                                    if (!searchText) {
                                                        self.allMovies = self.movies;
                                                    }
                                                    self.totalPage = responseDictionary[@"total_pages"];
                                                    [self.refreshControl endRefreshing];
                                                    self.segmentControl.hidden = NO;
                                                    if (self.isGrid) {
                                                        self.collectionView.hidden = NO;
                                                        [self.collectionView reloadData];
                                                    } else {
                                                        self.tableView.hidden = NO;
                                                        [self.tableView reloadData];
                                                    }
                                                    //NSLog(@"Response: %@", self.movies);
                                                } else {
                                                    NSLog(@"An error occurred: %@", error.description);
                                                    self.errorView.hidden = NO;
                                                    self.segmentControl.hidden = YES;
                                                    self.errorLabel.text = @"Network error";
                                                    if (self.isGrid) {
                                                        self.collectionView.hidden = YES;
                                                    } else {
                                                        self.tableView.hidden = YES;
                                                    }
                                                }
                                            }];
    [task resume];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    __weak MovieCellTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    
    NSDictionary *movieData = self.movies[indexPath.row];

    
    cell.titleLabel.text = movieData[@"title"];
    cell.synopsisLabel.text = movieData[@"overview"];
    
    NSString *imageUrl = [NSString stringWithFormat:@"https://image.tmdb.org/t/p/w154%@", movieData[@"poster_path"]];
    
    NSURLRequest *imgRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];
    if (![cell.selectedBackgroundView.backgroundColor isEqual:[UIColor purpleColor]]) {
        UIView *backgroundView = [[UIView alloc] init];
        backgroundView.backgroundColor = [UIColor purpleColor];
        cell.selectedBackgroundView = backgroundView;
    }
    
    [cell.posterImage setImageWithURLRequest:imgRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        cell.posterImage.alpha = 0.0;
        cell.posterImage.image = image;
        //[cell setNeedsLayout];
        [UIView animateWithDuration:0.5 animations:^(){
            cell.posterImage.alpha = 1.0;
        }];
    } failure:nil];

    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.movies.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MovieCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MovieCollectionViewCell" forIndexPath:indexPath];
    NSDictionary *movieData = self.movies[indexPath.row];
    NSString *imageUrl = [NSString stringWithFormat:@"https://image.tmdb.org/t/p/w154%@", movieData[@"poster_path"]];
    
    NSURLRequest *imgRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:imageUrl]];

    [cell.posterImage setImageWithURLRequest:imgRequest placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        cell.posterImage.alpha = 0.0;
        cell.posterImage.image = image;
        [cell setNeedsLayout];
        [UIView animateWithDuration:0.5 animations:^(){
            cell.posterImage.alpha = 1.0;
        }];
    } failure:nil];
    
    return cell;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UITableViewCell *cell;
    [self.searchBar resignFirstResponder];
    if ([segue.identifier isEqualToString:@"MovieDetail"]) {
        cell = sender;
        MovieDetailViewController *details = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        details.movie = self.movies[indexPath.row];
    } else if ([segue.identifier isEqualToString:@"ImageZoom"]) {
        UIButton *button = sender;
        cell = (UITableViewCell *)button.superview.superview;
        ImageZoomViewController *imageZoom = segue.destinationViewController;
        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
        imageZoom.movie = self.movies[indexPath.row];
    } else if ([segue.identifier isEqualToString:@"CollectionMovieDetail"]) {
        UIButton *button = sender;
        UICollectionViewCell *collCell = (UICollectionViewCell *)button.superview.superview;
        NSIndexPath *indexPath = [self.collectionView indexPathForCell:collCell];
        MovieDetailViewController *details = segue.destinationViewController;
        details.movie = self.movies[indexPath.row];
    }
}
- (IBAction)onGridChange:(UISegmentedControl *)sender {
    self.isGrid = !self.isGrid;
    if (self.isGrid) {
        self.collectionView.hidden = NO;
        self.tableView.hidden = YES;
        [self.collectionView reloadData];
    } else {
        self.collectionView.hidden = YES;
        self.tableView.hidden = NO;
        [self.tableView reloadData];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    UIScrollView *sv;
    if (!self.callInProgress) {
        if (self.isGrid) {
            sv = self.collectionView;
        } else {
            sv = self.tableView;
        }
        CGFloat soThreshold = sv.contentSize.height - 2*sv.bounds.size.height;
        
        if (sv.contentOffset.y > soThreshold && self.currentPage.intValue < self.totalPage.intValue) {
            self.currentPage = [NSNumber numberWithInt:(self.currentPage.intValue+1)];
            [self loadMovies:nil];
        }
    }
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = YES;
    self.movies = self.allMovies;
    if (self.isGrid) {
        [self.collectionView reloadData];
    } else {
        [self.tableView reloadData];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    searchBar.showsCancelButton = NO;
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    self.movies = self.allMovies;
    if (self.isGrid) {
        [self.collectionView reloadData];
    } else {
        [self.tableView reloadData];
    }
}
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    CGPoint cOffset;
    if (self.isGrid) {
        cOffset = self.collectionView.contentOffset;
        cOffset.y = 0;
        self.collectionView.contentOffset = cOffset;
    } else {
        cOffset = self.tableView.contentOffset;
        cOffset.y = 0;
        self.tableView.contentOffset = cOffset;
    }
    if (searchText.length >= 3) {
        /*
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K contains %@ OR %K contains %@", @"title", searchText, @"overview", searchText];
        self.movies =  [self.allMovies filteredArrayUsingPredicate:predicate];
        if (self.isGrid) {
            [self.collectionView reloadData];
        } else {
            [self.tableView reloadData];
        }
         */
        [self loadMovies:searchText];
    } else if (![self.movies isEqual:self.allMovies]) {
        self.movies = self.allMovies;
        if (self.isGrid) {
            [self.collectionView reloadData];
        } else {
            [self.tableView reloadData];
        }
    }
}

@end
