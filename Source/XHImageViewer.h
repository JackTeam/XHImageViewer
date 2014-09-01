//
//  XHImageViewer.h
//  XHImageViewer
//
//  Created by 曾 宪华 on 14-2-17.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507
//  本人QQ群（142557668）. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XHImageViewer;

typedef void (^willDismissWithSelectedViewBlock)(XHImageViewer *imageViewer,
                                                 UIImageView *selectedView);
typedef void (^didDismissWithSelectedViewBlock)(XHImageViewer *imageViewer,
                                                UIImageView *selectedView);
typedef void (^didChangeToImageViewBlock)(XHImageViewer *imageViewer,
                                          UIImageView *selectedView);

@protocol XHImageViewerDelegate <NSObject>

@optional
- (void)imageViewer:(XHImageViewer *)imageViewer
    willDismissWithSelectedView:(UIImageView *)selectedView;
- (void)imageViewer:(XHImageViewer *)imageViewer
    didDismissWithSelectedView:(UIImageView *)selectedView;
- (UIView *)customNavigationBarOfImageViewer:(XHImageViewer *)imageViewer;
- (void)imageViewer:(XHImageViewer *)imageViewer
    didChangeToImageView:(UIImageView *)selectedView;

@end

@interface XHImageViewer : UIView

@property(nonatomic, weak) id<XHImageViewerDelegate> delegate;

@property(nonatomic, assign) CGFloat backgroundScale;

@property(nonatomic, assign) BOOL disableTouchDismiss;

- (void)showWithImageViews:(NSArray *)views
              selectedView:(UIImageView *)selectedView;
- (id)initWithImageViewerWillDismissWithSelectedViewBlock:
          (willDismissWithSelectedViewBlock)willDismissWithSelectedViewBlock
                          didDismissWithSelectedViewBlock:
                              (didDismissWithSelectedViewBlock)
                          didDismissWithSelectedViewBlock
                                didChangeToImageViewBlock:
                                    (didChangeToImageViewBlock)
    didChangeToImageViewBlock;
@end
