//
//  __RJInnerWebView.h
//  RJWebView
//
//  Created by yirenjun@gmail.com on 16/1/15.
//  Copyright © 2016年 RJ. All rights reserved.
//

#ifndef __RJInnerWebView_h
#define __RJInnerWebView_h

@protocol __RJInnerWebView

- (double)estimatedProgress;

- (void)setCustomUserAgent:(NSString *)userAgent;
- (void)setApplicationNameForUserAgent:(NSString *)userAgent;

- (id)backForwardList;
- (BOOL)goToBackForwardItem:(id)item;
- (void)_loadBackForwardListFromOtherView:(id)view;

@end

#endif /* __RJInnerWebView_h */
