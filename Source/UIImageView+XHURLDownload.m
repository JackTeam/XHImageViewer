//
//  UIImageView+XHURLDownload.m
//  XHImageViewer
//
//  Created by 曾 宪华 on 14-2-18.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import "UIImageView+XHURLDownload.h"

#import <objc/runtime.h>

const char* const kXHURLPropertyKey   = "XHURLDownloadURLPropertyKey";
const char* const kCLLoadingStateKey  = "XHURLDownloadLoadingStateKey";
const char* const kCLLoadingViewKey   = "XHURLDownloadLoadingViewKey";

@implementation UIImageView (XHURLDownload)

+ (id)imageViewWithURL:(NSURL*)url autoLoading:(BOOL)autoLoading {
    UIImageView *view = [self new];
    view.url = url;
    if(autoLoading) {
        [view load];
    }
    return view;
}

+ (id)indicatorImageView {
    UIImageView *view = [self new];
    [view setDefaultLoadingView];
    
    return view;
}

+ (id)indicatorImageViewWithURL:(NSURL*)url autoLoading:(BOOL)autoLoading {
    UIImageView *view = [self imageViewWithURL:url autoLoading:autoLoading];
    [view setDefaultLoadingView];
    
    return view;
}

#pragma mark- Properties

- (NSURL*)url {
    return objc_getAssociatedObject(self, kXHURLPropertyKey);
}

- (void)setUrl:(NSURL *)url {
    [self setUrl:url autoLoading:NO];
}

- (void)setUrl:(NSURL *)url autoLoading:(BOOL)autoLoading {
    if(![url isEqual:self.url]) {
        objc_setAssociatedObject(self, kXHURLPropertyKey, url, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        
        if (url) {
            self.loadingState = UIImageViewURLDownloadStateWaitingForLoad;
        }
        else {
            self.loadingState = UIImageViewURLDownloadStateUnknown;
        }
    }
    
    if(autoLoading) {
        [self load];
    }
}

- (void)loadWithURL:(NSURL *)url {
    [self setUrl:url autoLoading:YES];
}

- (void)loadWithURL:(NSURL*)url completionBlock:(void(^)(UIImage *image, NSURL *url, NSError *error))handler {
    [self setUrl:url autoLoading:NO];
    [self loadWithCompletionBlock:handler];
}

- (UIImageViewURLDownloadState)loadingState {
    return (NSUInteger)([objc_getAssociatedObject(self, kCLLoadingStateKey) integerValue]);
}

- (void)setLoadingState:(UIImageViewURLDownloadState)loadingState {
    objc_setAssociatedObject(self, kCLLoadingStateKey, @(loadingState), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)loadingView {
    return objc_getAssociatedObject(self, kCLLoadingViewKey);
}

- (void)setLoadingView:(UIView *)loadingView {
    [self.loadingView removeFromSuperview];
    
    objc_setAssociatedObject(self, kCLLoadingViewKey, loadingView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    loadingView.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    loadingView.alpha  = 0;
    [self addSubview:loadingView];
}

- (void)setDefaultLoadingView {
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.frame = self.frame;
    indicator.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    indicator.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1];
    self.loadingView = indicator;
}

#pragma mark- Loading view

- (void)showLoadingView {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.loadingView.alpha = 1;
        if([self.loadingView respondsToSelector:@selector(startAnimating)]) {
            [self.loadingView performSelector:@selector(startAnimating)];
        }
    });
}

- (void)hideLoadingView {
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView animateWithDuration:0.3
                         animations:^{
                             self.loadingView.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             if([self.loadingView respondsToSelector:@selector(stopAnimating)]) {
                                 [self.loadingView performSelector:@selector(stopAnimating)];
                             }
                         }
         ];
    });
}

#pragma mark- Image downloading

+ (NSOperationQueue *)downloadQueue {
    static NSOperationQueue *_sharedQueue = nil;
    
    if(_sharedQueue==nil) {
        _sharedQueue = [NSOperationQueue new];
        [_sharedQueue setMaxConcurrentOperationCount:3];
    }
    
    return _sharedQueue;
}

+ (void)dataWithContentsOfURL:(NSURL *)url completionBlock:(void (^)(NSURL *, NSData *, NSError *))completion {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    [request setTimeoutInterval:5.0];
    
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[self downloadQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if(completion){
                                   completion(url, data, connectionError);
                               }
                           }
     ];
}

- (void)load {
    [self loadWithCompletionBlock:nil];
    
}

- (void)loadWithCompletionBlock:(void(^)(UIImage *image, NSURL *url, NSError *error))handler {
    self.loadingState = UIImageViewURLDownloadStateNowLoading;
    
    [self showLoadingView];
    
    // It could be more better by replacing with a method that has delegates like a progress.
    [UIImageView dataWithContentsOfURL:self.url
                       completionBlock:^(NSURL *url, NSData *data, NSError *error) {
                           UIImage *image = [self didFinishDownloadWithData:data forURL:url error:error];
                           
                           if(handler) {
                               handler(image, url, error);
                           }
                       }
     ];
}

- (UIImage *)didFinishDownloadWithData:(NSData *)data forURL:(NSURL *)url error:(NSError *)error {
    UIImage *image = [UIImage imageWithData:data];
    
    if([url isEqual:self.url]) {
        if(error) {
            self.loadingState = UIImageViewURLDownloadStateFailed;
        }
        else {
            [self performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
            self.loadingState = UIImageViewURLDownloadStateLoaded;
        }
        [self hideLoadingView];
    }
    return image;
}

- (void)setImage:(UIImage *)image forURL:(NSURL *)url {
    if([url isEqual:self.url]) {
        [self performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:NO];
        self.loadingState = UIImageViewURLDownloadStateLoaded;
        [self hideLoadingView];
    }
}

@end
