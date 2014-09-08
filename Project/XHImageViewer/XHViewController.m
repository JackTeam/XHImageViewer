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

#import "XHBottomToolBar.h"

@interface XHViewController () <XHImageViewerDelegate> {
  NSMutableArray *_imageViews;
}

@property (nonatomic, strong) XHBottomToolBar *bottomToolBar;

@end

@implementation XHViewController

- (void)likeButtonClciked:(UIButton *)sender {
    
}

- (XHBottomToolBar *)bottomToolBar {
    if (!_bottomToolBar) {
        _bottomToolBar = [[XHBottomToolBar alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 44)];
        [_bottomToolBar.likeButton addTarget:self action:@selector(likeButtonClciked:) forControlEvents:UIControlEventTouchUpInside];
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

  for (UIImageView *imageView in _imageViews) {
    NSInteger index = [_imageViews indexOfObject:imageView];
    UITapGestureRecognizer *gesture =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:@selector(tapHandle:)];
    imageView.userInteractionEnabled = YES;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [imageView addGestureRecognizer:gesture];

    if (index) {
      [imageView loadWithURL:[URLStoreManager getUrlWithIndex:index]
                         placeholer:[UIImage imageNamed:@"placeholder.jpeg"]
          showActivityIndicatorView:YES];
    } else {
      imageView.image = [UIImage imageNamed:@"screenshot.png"];
    }

    [self.view addSubview:imageView];
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)tapHandle:(UITapGestureRecognizer *)tap {
  XHImageViewer *imageViewer = [[XHImageViewer alloc]
      initWithImageViewerWillDismissWithSelectedViewBlock:
          ^(XHImageViewer *imageViewer, UIImageView *selectedView) {
              NSInteger index = [_imageViews indexOfObject:selectedView];
              NSLog(@"willDismissBlock index : %d", index);
          }
      didDismissWithSelectedViewBlock:^(XHImageViewer *imageViewer,
                                        UIImageView *selectedView) {
          NSInteger index = [_imageViews indexOfObject:selectedView];
          NSLog(@"didDismissBlock index : %d", index);
      }
      didChangeToImageViewBlock:^(XHImageViewer *imageViewer,
                                  UIImageView *selectedView) {
          NSInteger index = [_imageViews indexOfObject:selectedView];
          NSLog(@"changeBlock to index : %d", index);
      }];
  imageViewer.delegate = self;
  imageViewer.disableTouchDismiss = NO;
  [imageViewer showWithImageViews:_imageViews
                     selectedView:(UIImageView *)tap.view];
}

#pragma mark - XHImageViewerDelegate

- (UIView *)customBottomToolBarOfImageViewer:(XHImageViewer *)imageViewer {
    return self.bottomToolBar;
}

- (void)imageViewer:(XHImageViewer *)imageViewer
    willDismissWithSelectedView:(UIImageView *)selectedView {
  NSInteger index = [_imageViews indexOfObject:selectedView];
  NSLog(@"willDismiss index : %d", index);
}

- (void)imageViewer:(XHImageViewer *)imageViewer
    didDismissWithSelectedView:(UIImageView *)selectedView {
  NSInteger index = [_imageViews indexOfObject:selectedView];
  NSLog(@"didDismiss index : %d", index);
}

- (void)imageViewer:(XHImageViewer *)imageViewer
    didChangeToImageView:(UIImageView *)selectedView {
  NSInteger index = [_imageViews indexOfObject:selectedView];
  NSLog(@"change to index : %d", index);
}

@end
