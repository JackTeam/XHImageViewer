![image](https://github.com/JackTeam/XHImageViewer/raw/master/Screenshots/XHImageViewer.gif)

XHImageViewer
=============

XHImageViewer is images viewer, zoom image
## How to use ##
```objc
#import "XHImageViewer.h"    

XHImageViewer *imageViewer = [[XHImageViewer alloc] init];
imageViewer.delegate = self;
[imageViewer showWithImageViews:_imageViews selectedView:imageView];

// _imageViews is mutiple imageViews(subClass UIImageView or UIImageView)
// imageView is user touch imageView to selectedImageView
```

