//
//  XHViewController.m
//  XHImageViewer
//
//  Created by 曾 宪华 on 14-2-17.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507
//  本人QQ群（142557668）. All rights reserved.
//

#import "XHViewController.h"
#import "XHImageViewer.h"
#import "UIImageView+XHURLDownload.h"
#import "URLStoreManager.h"
#import "XHCustomImageView.h"
#import "XHBottomToolBar.h"

@interface XHViewController () <XHImageViewerDelegate> {
    NSMutableArray *_imageViews;
}

@property (nonatomic, strong) XHBottomToolBar *bottomToolBar;

@property (nonatomic, strong) XHImageViewer *imageViewer;

@end

@implementation XHViewController

- (void)likeButtonClicked:(UIButton *)sender {
    
}

- (void)shareButtonClicked:(UIButton *)sender {
    UIImage *currentImage = [_imageViewer currentImage];
    if (currentImage) {
        UIImageWriteToSavedPhotosAlbum(currentImage, nil, nil, nil);
    }
}

- (XHBottomToolBar *)bottomToolBar {
    if (!_bottomToolBar) {
        _bottomToolBar = [[XHBottomToolBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44)];
        [_bottomToolBar.likeButton addTarget:self action:@selector(likeButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomToolBar.shareButton addTarget:self action:@selector(shareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bottomToolBar;
}

#pragma mark - Life Cycle

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    _imageViews = [NSMutableArray array];
    [_imageViews
     addObject:[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 160, 200)]];
    [_imageViews addObject:[[UIImageView alloc]
                            initWithFrame:CGRectMake(160, 0, 160, 150)]];
    [_imageViews addObject:[[UIImageView alloc]
                            initWithFrame:CGRectMake(160, 150, 160, 50)]];
    [_imageViews addObject:[[UIImageView alloc]
                            initWithFrame:CGRectMake(0, 200, 320, 100)]];
    [_imageViews addObject:[[XHCustomImageView alloc]
                            initWithFrame:CGRectMake(0, 300, 320, 100)]];
    
    for (int index = 0; index < _imageViews.count; index ++) {
        UIImageView *imageView = [_imageViews objectAtIndex:index];
        UITapGestureRecognizer *gesture =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(tapHandle:)];
        imageView.userInteractionEnabled = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        [imageView addGestureRecognizer:gesture];
        
        if ([imageView isKindOfClass:[XHCustomImageView class]]) {
            // 不用做任何操作
            
            XHCustomImageView <XHImageURLDataSource> *dataSource = (XHCustomImageView <XHImageURLDataSource> *)imageView;
            [imageView loadWithURL:[NSURL URLWithString:[dataSource thnumbnailPhotoURLString]] placeholer:[UIImage imageNamed:@"placeholder.jpeg"]];
            [self.view addSubview:imageView];
            return;
        }
        if (index) {
            [imageView loadWithURL:[URLStoreManager getUrlWithIndex:index]
                        placeholer:[UIImage imageNamed:@"placeholder.jpeg"]
         showActivityIndicatorView:YES];
        } else {
            imageView.image = [UIImage imageNamed:@"1_1280x800.jpeg"];
        }
        
        [self.view addSubview:imageView];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tapHandle:(UITapGestureRecognizer *)tap {
    _imageViewer = [[XHImageViewer alloc]
                                  initWithImageViewerWillDismissWithSelectedViewBlock:
                                  ^(XHImageViewer *imageViewer, UIImageView *selectedView) {
                                      NSInteger index = [_imageViews indexOfObject:selectedView];
                                      NSLog(@"willDismissBlock index : %ld", (long)index);
                                  }
                                  didDismissWithSelectedViewBlock:^(XHImageViewer *imageViewer,
                                                                    UIImageView *selectedView) {
                                      NSInteger index = [_imageViews indexOfObject:selectedView];
                                      NSLog(@"didDismissBlock index : %ld", (long)index);
                                  }
                                  didChangeToImageViewBlock:^(XHImageViewer *imageViewer,
                                                              UIImageView *selectedView) {
                                      NSInteger index = [_imageViews indexOfObject:selectedView];
                                      [self.bottomToolBar.unLikeButton setTitle:[NSString stringWithFormat:@"%ld/%lu", index + 1, (unsigned long)_imageViews.count] forState:UIControlStateNormal];

                                  }];
    _imageViewer.delegate = self;
    _imageViewer.disableTouchDismiss = NO;
    [_imageViewer showWithImageViews:_imageViews
                       selectedView:(UIImageView *)tap.view];
    
    NSInteger index = [_imageViews indexOfObject:(UIImageView *)tap.view];
    [self.bottomToolBar.unLikeButton setTitle:[NSString stringWithFormat:@"%ld/%lu", index + 1, (unsigned long)_imageViews.count] forState:UIControlStateNormal];
}

#pragma mark - XHImageViewerDelegate

- (UIView *)customBottomToolBarOfImageViewer:(XHImageViewer *)imageViewer {
    return self.bottomToolBar;
}

@end
