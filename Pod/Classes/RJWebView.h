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

@property (nonatomic, assign) IBInspectable BOOL needsToUseWK;

@property (nonatomic, weak) IBOutlet id<RJWebViewDelegate> delegate;

@property (nonatomic, readonly) UIScrollView * _Nonnull scrollView;

// 配置项
@property (nonatomic) BOOL allowsBackForwardNavigationGestures;     // 开启前进后退滑动手势，目前只在WK内核时有效
@property (nonatomic) BOOL allowsInlineMediaPlayback;
@property (nonatomic) BOOL mediaPlaybackRequiresUserAction;
@property (nonatomic) BOOL scalesPageToFit;

// Key-Value observing (KVO) compliant
@property (nonatomic, readonly, copy)                           NSURL *     _Nullable URL;
@property (nonatomic, readonly, copy)                           NSString *  _Nullable title;
@property (nonatomic, readonly, assign)                         double      estimatedProgress;
@property (nonatomic, readonly, assign, getter=isLoading)       BOOL        loading;
@property (nonatomic, readonly, assign, getter=canGoBack)       BOOL        canGoBack;
@property (nonatomic, readonly, assign, getter=canGoForward)    BOOL        canGoForward;

// 设置Cookies
//+ (void)setupCookies:(NSArray *_Nonnull)cookies;

// 初始化
- (instancetype _Null_unspecified)initWithFrame:(CGRect)frame;
- (instancetype _Null_unspecified)initWithFrame:(CGRect)frame withWK:(BOOL)needsToUseWK;

// 读取和设置UserAgent
- (NSString * _Nullable)currentUserAgent;
- (void)setCustomUserAgent:(NSString * _Nullable)userAgent;
- (void)setApplicationNameForUserAgent:(NSString * _Nullable)appName;

// WebView相关操作
- (void)loadRequest:(NSURLRequest * _Nonnull)request;
- (void)loadHTMLString:(NSString *_Nonnull)string baseURL:(NSURL *_Nonnull)baseURL;
- (void)stopLoading;
- (void)reload;
- (void)goBack;
- (void)goForward;

// JS调用
- (nullable NSString *)stringByEvaluatingJavaScriptFromString:(NSString * _Nonnull)script;
- (void)evaluateJavaScript:(NSString * _Nonnull)javaScriptString completionHandler:(void (^ _Nullable)(id _Nullable, NSError * _Nullable))completionHandler;

@end
