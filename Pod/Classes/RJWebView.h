//
//  RJWebView.h
//  RJWebView
//
//  Created by yirenjun@gmail.com on 15/2/6.
//  Copyright © 2016年 RJ. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RJWebViewDelegate.h"
#import <Foundation/Foundation.h>
#import <WebViewJavascriptBridge/WebViewJavascriptBridge.h>

@interface RJWebView : UIView

@property (nonatomic, weak) IBOutlet id<RJWebViewDelegate> delegate;

// 开启前进后退滑动手势 目前只在iOS8有效
@property (nonatomic) BOOL allowsBackForwardNavigationGestures;
@property (nonatomic) BOOL allowsInlineMediaPlayback;
@property (nonatomic) BOOL mediaPlaybackRequiresUserAction;

// webview内部的scrollview
@property (nonatomic, readonly) UIScrollView *scrollView;

// key-value observing (KVO) compliant
@property (nonatomic, readonly, copy) NSURL *URL;
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly) double estimatedProgress;
@property (nonatomic, readonly, getter=isLoading) BOOL loading;
@property (nonatomic, readonly, getter=canGoBack) BOOL canGoBack;
@property (nonatomic, readonly, getter=canGoForward) BOOL canGoForward;

- (void)setDelegate:(id<RJWebViewDelegate>)delegate;

- (void)rj_setCustomUserAgent:(NSString *)userAgent;
- (void)rj_setApplicationNameForUserAgent:(NSString *)appName;

- (NSString *)currentUserAgent;

- (void)loadRequest:(NSURLRequest *)request;
- (void)loadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL;
- (void)reload;
- (void)stopLoading;

- (void)goBack;
- (void)goForward;

- (void)setupCookies:(NSArray *)cookies;

- (nullable NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script;
- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler;


- (instancetype)initWithFrame:(CGRect)frame;
- (instancetype)initWithFrame:(CGRect)frame classic:(BOOL)classic;

@end
