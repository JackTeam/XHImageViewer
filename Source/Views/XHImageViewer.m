//
//  XHImageViewer.m
//  XHImageViewer
//
//  Created by 曾 宪华 on 14-2-17.
//  Copyright (c) 2014年 嗨，我是曾宪华(@xhzengAIB)，曾加入YY Inc.担任高级移动开发工程师，拍立秀App联合创始人，热衷于简洁、而富有理性的事物 QQ:543413507 主页:http://zengxianhua.com All rights reserved.
//

#import "XHImageViewer.h"
#import "XHViewState.h"
#import "XHZoomingImageView.h"
#import "UIImageView+XHURLDownload.h"

#define kXHImageViewerBaseTopToolBarTag 100
#define kXHImageViewerBaseBottomToolBarTag 200

@interface XHImageViewer () <UIScrollViewDelegate>

@property(nonatomic, strong) UIScrollView *scrollView;
@property(nonatomic, strong) NSArray *imgViews;

@property(nonatomic, copy) WillDismissWithSelectedViewBlock willDismissWithSelectedViewBlock;
@property(nonatomic, copy) DidDismissWithSelectedViewBlock didDismissWithSelectedViewBlock;
@property(nonatomic, copy) DidChangeToImageViewBlock didChangeToImageViewBlock;

@end

@implementation XHImageViewer

- (void)setImageViewsFromArray:(NSArray *)views {
    NSMutableArray *imgViews = [NSMutableArray array];
    for (id obj in views) {
        if ([obj isKindOfClass:[UIImageView class]]) {
            [imgViews addObject:obj];
            
            UIImageView *view = obj;
            
            XHViewState *state = [XHViewState viewStateForView:view];
            [state setStateWithView:view];
            
            view.userInteractionEnabled = NO;
        }
    }
    _imgViews = [imgViews copy];
}

- (UIImage *)currentImage {
    return [self currentView].image;
}

- (void)showWithImageViews:(NSArray *)views
              selectedView:(UIImageView *)selectedView {
    [self setImageViewsFromArray:views];
    
    if (_imgViews.count > 0) {
        if (![selectedView isKindOfClass:[UIImageView class]] ||
            ![_imgViews containsObject:selectedView]) {
            selectedView = _imgViews[0];
        }
        [self showWithSelectedView:selectedView];
    }
}

#pragma mark - Life Cycle

- (void)_setup {
    self.backgroundColor = [UIColor colorWithWhite:0.1 alpha:1];
    self.backgroundScale = 0.95;
    
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureRecognizer:)];
    panGestureRecognizer.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:panGestureRecognizer];
}

- (id)init {
    self = [self initWithFrame:CGRectZero];
    if (self) {
        [self _setup];
    }
    return self;
}

- (id)initWithImageViewerWillDismissWithSelectedViewBlock:(WillDismissWithSelectedViewBlock)willDismissWithSelectedViewBlock
                          didDismissWithSelectedViewBlock:(DidDismissWithSelectedViewBlock)didDismissWithSelectedViewBlock
                                didChangeToImageViewBlock:(DidChangeToImageViewBlock)didChangeToImageViewBlock {
    
    if (self = [self initWithFrame:CGRectZero]) {
        self.willDismissWithSelectedViewBlock = willDismissWithSelectedViewBlock;
        self.didDismissWithSelectedViewBlock = didDismissWithSelectedViewBlock;
        self.didChangeToImageViewBlock = didChangeToImageViewBlock;
        
        [self _setup];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        [self _setup];
    }
    return self;
}

#pragma mark - Properties

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:[backgroundColor colorWithAlphaComponent:0]];
}

- (NSInteger)pageIndex {
    return (_scrollView.contentOffset.x / _scrollView.frame.size.width);
}

#pragma mark - Getter Method

- (UIView *)topToolBar {
    UIView *topToolBar = [self viewWithTag:kXHImageViewerBaseTopToolBarTag];
    if (!topToolBar) {
        if ([self.delegate respondsToSelector:@selector(customTopToolBarOfImageViewer:)]) {
            topToolBar = [self.delegate customTopToolBarOfImageViewer:self];
            topToolBar.frame = CGRectMake(0, -CGRectGetHeight(topToolBar.bounds), CGRectGetWidth(topToolBar.bounds), CGRectGetHeight(topToolBar.bounds));
        }
    }
    
    return topToolBar;
}

- (UIView *)bottomToolBar {
    UIView *bottomToolBar = [self viewWithTag:kXHImageViewerBaseBottomToolBarTag];
    if (!bottomToolBar) {
        if ([self.delegate respondsToSelector:@selector(customBottomToolBarOfImageViewer:)]) {
            bottomToolBar = [self.delegate customBottomToolBarOfImageViewer:self];
            bottomToolBar.tag = kXHImageViewerBaseBottomToolBarTag;
            bottomToolBar.frame = CGRectMake(0, CGRectGetHeight(self.bounds), CGRectGetWidth(bottomToolBar.bounds), CGRectGetHeight(bottomToolBar.bounds));
        }
    }
    return bottomToolBar;
}

#pragma mark - View management

- (UIImageView *)currentView {
    return [_imgViews objectAtIndex:self.pageIndex];
}

- (void)showWithSelectedView:(UIImageView *)selectedView {
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    const NSInteger currentPage = [_imgViews indexOfObject:selectedView];
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
    UIView *topToolBar = [self topToolBar];
    if (topToolBar) {
        if (![self.subviews containsObject:topToolBar]) {
            topToolBar.alpha = 0.0;
            [self addSubview:topToolBar];
        }
    }
    
    UIView *bottomToolBar = [self bottomToolBar];
    if (bottomToolBar) {
        if (![self.subviews containsObject:bottomToolBar]) {
            bottomToolBar.alpha = 0.0;
            [self addSubview:bottomToolBar];
        }
    }
    
    CGRect scrollViewFrame = self.bounds;
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:scrollViewFrame];
        _scrollView.pagingEnabled = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.backgroundColor =
        [self.backgroundColor colorWithAlphaComponent:1];
        _scrollView.alpha = 0;
        _scrollView.delegate = self;
    }
    
    [self insertSubview:_scrollView atIndex:0];
    [window addSubview:self];
    
    const CGFloat fullW = window.frame.size.width;
    const CGFloat fullH = window.frame.size.height;
    
    selectedView.frame =
    [window convertRect:selectedView.frame fromView:selectedView.superview];
    [window addSubview:selectedView];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         _scrollView.alpha = 1;
                         window.rootViewController.view.transform = CGAffineTransformMakeScale(
                                                                                               self.backgroundScale, self.backgroundScale);
                         
                         selectedView.transform = CGAffineTransformIdentity;
                         
                         CGSize size = (selectedView.image) ? selectedView.image.size
                         : selectedView.frame.size;
                         CGFloat ratio = MIN(fullW / size.width, fullH / size.height);
                         CGFloat W = ratio * size.width;
                         CGFloat H = ratio * size.height;
                         selectedView.frame =
                         CGRectMake((fullW - W) / 2, (fullH - H) / 2, W, H);
                     }
                     completion:^(BOOL finished) {
                         _scrollView.contentSize = CGSizeMake(_imgViews.count * fullW, 0);
                         _scrollView.contentOffset = CGPointMake(currentPage * fullW, 0);
                         
                         UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]
                                                            initWithTarget:self
                                                            action:@selector(tappedScrollView:)];
                         [_scrollView addGestureRecognizer:gesture];
                         
                         for (UIImageView *view in _imgViews) {
                             view.transform = CGAffineTransformIdentity;
                             
                             if ([view respondsToSelector:@selector(largePhotoURLString)]) {
                                 UIImageView <XHImageURLDataSource> *dataSource = (UIImageView <XHImageURLDataSource> *)view;
                                 
                                 [view loadWithURL:[NSURL URLWithString:[dataSource largePhotoURLString]]];
                             }
                             
                             CGSize size = (view.image) ? view.image.size : view.frame.size;
                             CGFloat ratio = MIN(fullW / size.width, fullH / size.height);
                             CGFloat W = ratio * size.width;
                             CGFloat H = ratio * size.height;
                             view.frame = CGRectMake((fullW - W) / 2, (fullH - H) / 2, W, H);
                             
                             XHZoomingImageView *tmp = [[XHZoomingImageView alloc]
                                                        initWithFrame:CGRectMake([_imgViews indexOfObject:view] * fullW,
                                                                                 0, fullW, fullH)];
                             tmp.imageView = view;
                             
                             [_scrollView addSubview:tmp];
                         }
                         
                         [self showToolBar];
                     }];
}

- (void)showToolBar {
    [UIView animateWithDuration:0.3 animations:^{
        UIView *topToolBar = [self topToolBar];
        UIView *bottomToolBar = [self bottomToolBar];
        topToolBar.frame = CGRectMake(0, 0, CGRectGetWidth(topToolBar.bounds), CGRectGetHeight(topToolBar.bounds));
        topToolBar.alpha = 1.0;
        
        bottomToolBar.frame = CGRectMake(0, CGRectGetHeight(self.bounds) - CGRectGetHeight(bottomToolBar.bounds), CGRectGetWidth(bottomToolBar.bounds), CGRectGetHeight(bottomToolBar.bounds));
        bottomToolBar.alpha = 1.0;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismissToolBar {
    [UIView animateWithDuration:0.3 animations:^{
        UIView *topToolBar = [self topToolBar];
        UIView *bottomToolBar = [self bottomToolBar];
        topToolBar.frame = CGRectMake(0, -CGRectGetHeight(topToolBar.bounds), CGRectGetWidth(topToolBar.bounds), CGRectGetHeight(topToolBar.bounds));
        topToolBar.alpha = 0.0;
        
        bottomToolBar.frame = CGRectMake(0, CGRectGetHeight(self.bounds), CGRectGetWidth(bottomToolBar.bounds), CGRectGetHeight(bottomToolBar.bounds));
        bottomToolBar.alpha = 0.0;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)prepareToDismiss {
    UIImageView *currentView = [self currentView];
    
    if ([self.delegate respondsToSelector:@selector(imageViewer:willDismissWithSelectedView:)]) {
        [self.delegate imageViewer:self willDismissWithSelectedView:currentView];
    }
    
    if (self.willDismissWithSelectedViewBlock) {
        self.willDismissWithSelectedViewBlock(self, currentView);
    }
    
    [self dismissToolBar];
    
    for (UIImageView *view in _imgViews) {
        if (view != currentView) {
            XHViewState *state = [XHViewState viewStateForView:view];
            view.transform = CGAffineTransformIdentity;
            view.frame = state.frame;
            view.transform = state.transform;
            [state.superview addSubview:view];
        }
    }
}

- (void)dismissWithAnimate {
    UIImageView *currentView = [self currentView];
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    
    CGRect rct = currentView.frame;
    currentView.transform = CGAffineTransformIdentity;
    currentView.frame = [window convertRect:rct fromView:currentView.superview];
    [window addSubview:currentView];
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         _scrollView.alpha = 0;
                         window.rootViewController.view.transform = CGAffineTransformIdentity;
                         
                         XHViewState *state = [XHViewState viewStateForView:currentView];
                         currentView.frame =
                         [window convertRect:state.frame fromView:state.superview];
                         currentView.transform = state.transform;
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             XHViewState *state = [XHViewState viewStateForView:currentView];
                             currentView.transform = CGAffineTransformIdentity;
                             currentView.frame = state.frame;
                             currentView.transform = state.transform;
                             [state.superview addSubview:currentView];
                             
                             for (UIView *view in _imgViews) {
                                 if ([view respondsToSelector:@selector(largePhotoURLString)]) {
                                     UIImageView <XHImageURLDataSource> *dataSource = (UIImageView <XHImageURLDataSource> *)view;
                                     [((UIImageView *)view) loadWithURL:[NSURL URLWithString:[dataSource thnumbnailPhotoURLString]]];
                                 }
                                 XHViewState *_state = [XHViewState viewStateForView:view];
                                 view.userInteractionEnabled = _state.userInteratctionEnabled;
                             }
                             [self removeFromSuperview];
                             
                             if ([self.delegate
                                  respondsToSelector:@selector(imageViewer:didDismissWithSelectedView:)]) {
                                 [self.delegate imageViewer:self
                                 didDismissWithSelectedView:currentView];
                             }
                             
                             if (self.didDismissWithSelectedViewBlock) {
                                 self.didDismissWithSelectedViewBlock(self, currentView);
                             }
                         }
                     }];
}

#pragma mark - Gesture events

- (void)tappedScrollView:(UITapGestureRecognizer *)sender {
    if (self.disableTouchDismiss) {
        return;
    }
    [self prepareToDismiss];
    [self dismissWithAnimate];
}

- (void)handlePanGestureRecognizer:(UIPanGestureRecognizer *)sender {
    if (self.disableTouchDismiss) {
        return;
    }
    static UIImageView *currentView = nil;
    
    if (sender.state == UIGestureRecognizerStateBegan) {
        currentView = [self currentView];
        
        UIView *targetView = currentView.superview;
        while (![targetView isKindOfClass:[XHZoomingImageView class]]) {
            targetView = targetView.superview;
        }
        
        if (((XHZoomingImageView *)targetView).isViewing) {
            currentView = nil;
        } else {
            UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
            currentView.frame =
            [window convertRect:currentView.frame fromView:currentView.superview];
            [window addSubview:currentView];
            
            [self prepareToDismiss];
        }
    }
    
    if (currentView) {
        if (sender.state == UIGestureRecognizerStateEnded) {
            if (_scrollView.alpha > 0.5) {
                [self showWithSelectedView:currentView];
            } else {
                [self dismissWithAnimate];
            }
            currentView = nil;
        } else {
            CGPoint p = [sender translationInView:self];
            
            CGAffineTransform transform = CGAffineTransformMakeTranslation(0, p.y);
            transform = CGAffineTransformScale(transform, 1 - fabs(p.y) / 1000,
                                               1 - fabs(p.y) / 1000);
            currentView.transform = transform;
            
            CGFloat r = 1 - fabs(p.y) / 200;
            _scrollView.alpha = MAX(0, MIN(1, r));
        }
    }
}

#pragma mark - UIScrollView delegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    
    if ([self.delegate respondsToSelector:@selector(imageViewer:didChangeToImageView:)]) {
        [self.delegate imageViewer:self didChangeToImageView:[self currentView]];
    }
    
    if (self.didChangeToImageViewBlock) {
        self.didChangeToImageViewBlock(self, [self currentView]);
    }
}

@end
