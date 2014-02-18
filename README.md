![image](https://github.com/JackTeam/XHImageViewer/raw/master/Screenshots/XHImageViewer.gif)
XHImageViewer
=============
XHImageViewer is images viewer, zoom image

## How to use
Easy to drop into your project. You can add this feature to your own project, `XHImageViewer` is easy-to-use.   
```objc
#import "XHImageViewer.h"    

XHImageViewer *imageViewer = [[XHImageViewer alloc] init];
imageViewer.delegate = self;
[imageViewer showWithImageViews:_imageViews selectedView:imageView];

_imageViews is mutiple imageViews(subClass UIImageView or UIImageView)
imageView is user touch imageView to selectedImageView
```

Easy to use download web image form the open source.
```objc
#import "UIImageView+XHURLDownload.h"

UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 160, 200)]
[imageView setDefaultLoadingView];
[imageView loadWithURL:[NSURL URLWithString:@"http://www.pailixiu.com/IMG_1388.JPG"]];
```

## Profile

[CocosPods](http://cocosPods.org) is the recommended methods of installation XHPathCover, just add the following line to `Profile`:

```
pod 'XHImageViewer', '~> 0.1.0'
```

## Lincense ##

`XHImageViewer` is available under the MIT license. See the LICENSE file for more info.
