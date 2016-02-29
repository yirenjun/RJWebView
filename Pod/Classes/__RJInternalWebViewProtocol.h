//
//  __RJInternalWebViewProtocol.h
//  RJWebView
//
//  Created by yirenjun@gmail.com on 15/2/6.
//  Copyright © 2016年 RJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RJWebView.h"

@protocol __RJInternalWebViewProtocol <NSObject>

@required

@property (nonatomic) BOOL allowsBackForwardNavigationGestures;
@property (nonatomic) BOOL allowsInlineMediaPlayback;
@property (nonatomic) BOOL mediaPlaybackRequiresUserAction;
@property (nonatomic) BOOL scalesPageToFit;

@property (nonatomic, readonly, copy)                           NSURL *     _Nullable URL;
@property (nonatomic, readonly, copy)                           NSString *  _Nullable title;
@property (nonatomic, readonly, assign)                         double      estimatedProgress;
@property (nonatomic, readonly, assign, getter=isLoading)       BOOL        loading;
@property (nonatomic, readonly, assign, getter=canGoBack)       BOOL        canGoBack;
@property (nonatomic, readonly, assign, getter=canGoForward)    BOOL        canGoForward;

- (void)setDelegate:(_Nullable id<RJWebViewDelegate>)delegate;

- (UIScrollView * _Nonnull)scrollView;

- (NSString * _Nullable)currentUserAgent;
- (void)setCustomUserAgent:(NSString * _Nullable)userAgent;
- (void)setApplicationNameForUserAgent:(NSString * _Nullable)appName;

- (void)loadRequest:(NSURLRequest * _Nonnull)request;
- (void)loadHTMLString:(NSString *_Nonnull)string baseURL:(NSURL *_Nonnull)baseURL;
- (void)stopLoading;
- (void)reload;
- (void)goBack;
- (void)goForward;

- (nullable NSString *)stringByEvaluatingJavaScriptFromString:(NSString * _Nonnull)script;
- (void)evaluateJavaScript:(NSString * _Nonnull)javaScriptString completionHandler:(void (^ _Nullable)(id _Nullable, NSError * _Nullable))completionHandler;

@end
