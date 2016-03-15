//
//  XHBottomToolBar.m
//  XHImageViewer
//
//  Created by 曾 宪华 on 14-9-8.
//  Copyright (c) 2014年 嗨，我是曾宪华(@xhzengAIB)，曾加入YY Inc.担任高级移动开发工程师，拍立秀App联合创始人，热衷于简洁、而富有理性的事物 QQ:543413507 主页:http://zengxianhua.com All rights reserved.
//

#import "XHBottomToolBar.h"

@interface XHBottomToolBar ()

@end

@implementation XHBottomToolBar

- (UIButton *)likeButton {
    if (!_likeButton) {
        _likeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _likeButton.frame = CGRectMake(10, 0, 80, CGRectGetHeight(self.bounds));
        [_likeButton setTitle:@"赞100" forState:UIControlStateNormal];
        [self addSubview:_likeButton];
    }
    return _likeButton;
}

- (UIButton *)unLikeButton {
    if (!_unLikeButton) {
        _unLikeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _unLikeButton.frame = CGRectMake(120, 0, 80, CGRectGetHeight(self.bounds));
        [self addSubview:_unLikeButton];
    }
    return _unLikeButton;
}

- (UIButton *)shareButton {
    if (!_shareButton) {
        _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shareButton setTitle:@"收藏" forState:UIControlStateNormal];
        _shareButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - 90, 0, 80, CGRectGetHeight(self.bounds));
        [self addSubview:_shareButton];
    }
    return _shareButton;
}

#pragma mark - Life Cycle

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor blackColor];
    }
    return self;
}

@end
