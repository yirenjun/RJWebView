//
//  __RJWKWebView.h
//  RJWebView
//
//  Created by yirenjun@gmail.com on 15/2/6.
//  Copyright © 2016年 RJ. All rights reserved.
//

#import <WebKit/WebKit.h>
#import "__RJWebViewProtocol.h"

@interface __RJWKWebView : WKWebView <RJWebViewProtocolInternal>

@end
