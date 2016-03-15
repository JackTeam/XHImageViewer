//
//  URLStoreManager.m
//  XHImageViewer
//
//  Created by 曾 宪华 on 14-2-18.
//  Copyright (c) 2014年 嗨，我是曾宪华(@xhzengAIB)，曾加入YY Inc.担任高级移动开发工程师，拍立秀App联合创始人，热衷于简洁、而富有理性的事物 QQ:543413507 主页:http://zengxianhua.com All rights reserved.
//

#import "URLStoreManager.h"

@implementation URLStoreManager

+ (NSURL *)getUrlWithIndex:(NSInteger)index {
    NSURL *url = nil;
    switch (index) {
        case 0:
            url = [NSURL URLWithString:@"http://d.hiphotos.baidu.com/image/h%3D200/sign=22e31b3d324e251ffdf7e3f89787c9c2/72f082025aafa40f282c77daa964034f79f019ca.jpg"];
            break;
        case 2:
            url = [NSURL URLWithString:@"http://pic1a.nipic.com/2008-11-07/20081179265582_2.jpg"];
            break;
        case 1:
            url = [NSURL URLWithString:@"http://pic5.nipic.com/20100202/3760162_130224079498_2.jpg"];
            break;
        case 3:
            url = [NSURL URLWithString:@"http://pic6.nipic.com/20100423/4782353_093056703685_2.jpg"];
            break;
        default:
            break;
    }
    return url;
}
@end
