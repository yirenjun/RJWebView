//
//  RJWebViewDelegate.h
//  RJWebView
//
//  Created by yirenjun@gmail.com on 15/3/20.
//  Copyright © 2016年 RJ. All rights reserved.
//

#ifndef Pods_RJWebViewDelegate_h
#define Pods_RJWebViewDelegate_h

@class RJWebView;

@protocol RJWebViewDelegate <UIWebViewDelegate>

@optional

- (BOOL)webView:(RJWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType;
- (void)webViewDidStartLoad:(RJWebView *)webView;
- (void)webViewDidFinishLoad:(RJWebView *)webView;
- (void)webView:(RJWebView *)webView didFailLoadWithError:(NSError *)error;

@end

#endif
