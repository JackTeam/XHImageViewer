//
//  XHImageURLDataSource.h
//  XHImageViewer
//
//  Created by Jack_iMac on 15/2/9.
//  Copyright (c) 2015年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507 本人QQ群（142557668）. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol XHImageURLDataSource <NSObject>

- (NSString *)largePhotoURLString;

- (NSString *)thnumbnailPhotoURLString;

@end
