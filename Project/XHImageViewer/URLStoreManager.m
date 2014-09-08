//
//  URLStoreManager.m
//  XHImageViewer
//
//  Created by 曾 宪华 on 14-2-18.
//  Copyright (c) 2014年 曾宪华 开发团队(http://iyilunba.com ) 本人QQ:543413507
//  本人QQ群（142557668）. All rights reserved.
//

#import "URLStoreManager.h"

@implementation URLStoreManager

+ (NSURL *)getUrlWithIndex:(NSInteger)index {
  NSURL *url = nil;
  switch (index) {
  case 0:
    break;
  case 1:
    url = [NSURL URLWithString:@"http://www.pailixiu.com/IMG_1388.JPG"];
    break;
  case 2:
    url = [NSURL URLWithString:@"http://pic6.nipic.com/20100423/4782353_093056703685_2.jpg"];
    break;
  case 3:
    url = [NSURL URLWithString:@"http://www.pailixiu.com/IMG_1573.PNG"];
    break;
  default:
    break;
  }
  return url;
}
@end
