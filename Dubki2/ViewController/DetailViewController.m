//
//  DetailViewController.m
//  Dubki2
//
//  Created by Игорь Моренко on 19.11.15.
//  Copyright © 2015 LionSoft LLC. All rights reserved.
//

#import "DetailViewController.h"

#pragma mark - Private Interface

@interface DetailViewController () <UIScrollViewDelegate>

@end

#pragma mark - Implementation

@implementation DetailViewController

UIScrollView *scrollView;
UIImageView *imageView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:self.imageName]];
    
    scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
    //scrollView.backgroundColor = [UIColor blackColor];
    scrollView.contentSize = imageView.bounds.size;
    scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    scrollView.delegate = self;
    scrollView.minimumZoomScale = 0.1;
    scrollView.maximumZoomScale = 4.0;
    
    [scrollView addSubview:imageView];
    [self.view addSubview:scrollView];
    
    [self setupGestureRecognizer];
    //scrollView.contentOffset = CGPoint(x: 1000, y: 450)
    //scrollView.zoomScale = 1.0
    [self setZoomScale];
    [self scrollViewDidZoom:scrollView];
}

- (void)viewWillLayoutSubviews {
    [self setZoomScale];
}

- (void)setZoomScale {
    CGSize imageViewSize = imageView.bounds.size;
    CGSize scrollViewSize = scrollView.bounds.size;
    CGFloat widthScale = scrollViewSize.width / imageViewSize.width;
    CGFloat heightScale = scrollViewSize.height / imageViewSize.height;
    
    scrollView.minimumZoomScale = MIN(widthScale, heightScale);
    scrollView.zoomScale = scrollView.minimumZoomScale; //1.0;
}

- (void)setupGestureRecognizer {
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [scrollView addGestureRecognizer:doubleTap];
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)recognizer {
    
    if (scrollView.zoomScale > scrollView.minimumZoomScale) {
        [scrollView setZoomScale:scrollView.minimumZoomScale animated:YES];
    } else {
        [scrollView setZoomScale:(scrollView.maximumZoomScale/2) animated:YES];
    }
}

#pragma mark - Scroll view delegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGSize imageViewSize = imageView.frame.size;
    CGSize scrollViewSize = scrollView.bounds.size;
    
    CGFloat verticalPadding = (imageViewSize.height < scrollViewSize.height ? (scrollViewSize.height - imageViewSize.height) / 2 : 0);
    CGFloat horizontalPadding = (imageViewSize.width < scrollViewSize.width ? (scrollViewSize.width - imageViewSize.width) / 2 : 0);
    
    scrollView.contentInset = UIEdgeInsetsMake(verticalPadding, horizontalPadding, verticalPadding, horizontalPadding);
}

@end
