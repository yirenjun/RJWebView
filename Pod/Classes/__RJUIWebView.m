//
//  __RJUIWebView.m
//  RJWebView
//
//  Created by yirenjun@gmail.com on 15/2/6.
//  Copyright © 2016年 RJ. All rights reserved.
//

#import "__RJUIWebView.h"
#import <objc/runtime.h>
#import <objc/message.h>

#pragma mark - __InnerWebFrame

@protocol __InnerWebFrame

- (BOOL)isMainFrame;

@end

#pragma mark - __InnerWebViewProtocol

@protocol __InnerWebViewProtocol

- (double)estimatedProgress;

- (void)setCustomUserAgent:(NSString *)userAgent;
- (void)setApplicationNameForUserAgent:(NSString *)userAgent;

- (NSString *)userAgentForURL:(NSURL *)URL;

- (id)backForwardList;
- (BOOL)goToBackForwardItem:(id)item;
- (void)_loadBackForwardListFromOtherView:(id)view;

@end

#pragma mark - __BrowserViewProtocol

@protocol __BrowserViewProtocol <NSObject>

- (id<__InnerWebViewProtocol>)webView;

@end

#pragma mark - __RJUIWebView

@interface UIWebView (__RJUIWebView)

- (void)webView:(id)webview didReceiveTitle:(NSString *)title forFrame:(id<__InnerWebFrame>)frame;
- (void)webView:(id)view didStartProvisionalLoadForFrame:(id<__InnerWebFrame>)frame;
- (void)webView:(id)view didFinishLoadForFrame:(id<__InnerWebFrame>)frame;
- (void)webView:(id)view didChangeLocationWithinPageForFrame:(id<__InnerWebFrame>)frame;

@end

@interface __RJUIWebView (Inner)

- (id<__BrowserViewProtocol>)rjDynamicHack__browserView;
- (void)rjDynamicHack__setDrawInWebThread:(BOOL)webThread;

@end

@implementation __RJUIWebView

@synthesize allowsBackForwardNavigationGestures;
@dynamic scrollView;

@synthesize URL;
@synthesize title;
@synthesize estimatedProgress;

#pragma mark - init

- (instancetype)_initWithFrame:(CGRect)frame
{
    return [[self initWithFrame:frame] setup];
}

- (void)awakeFromNib
{
    [self setup];
}

- (instancetype)setup
{
    [self rjDynamicHack__setDrawInWebThread:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webProgressEstimateChanged:) name:@"WebProgressEstimateChangedNotification" object:[self innerWebView]];
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"WebProgressEstimateChangedNotification" object:[self innerWebView]];
}

- (id<__BrowserViewProtocol>)innerBrowserView
{
    return [self rjDynamicHack__browserView];
}

- (id<__InnerWebViewProtocol>)innerWebView
{
    return [[self innerBrowserView] webView];
}

- (void)rj_setCustomUserAgent:(NSString *)userAgent
{
    [[self innerWebView] setCustomUserAgent:userAgent];
}

- (void)rj_setApplicationNameForUserAgent:(NSString *)appName
{
    [[self innerWebView] setApplicationNameForUserAgent:appName];
}

- (NSString *)currentUserAgent
{
    return [[self innerWebView] userAgentForURL:nil];
}

- (void)setupCookies:(NSArray *)cookies
{
    for (NSHTTPCookie *cookie in cookies)
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
}

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler
{
    NSString *string = [self stringByEvaluatingJavaScriptFromString:javaScriptString];
    if (completionHandler)
        completionHandler(string, nil);
}

#pragma mark - notification

- (void)webProgressEstimateChanged:(NSNotification *)note
{
    id value = [note.userInfo objectForKey:@"WebProgressEstimatedProgressKey"];
    if (value != nil) {
        [self setValue:value forKey:@"estimatedProgress"];
    }
}

#pragma mark - override 

- (void)webView:(id)webview didReceiveTitle:(NSString *)frameTitle forFrame:(id<__InnerWebFrame>)frame
{
    if ([frame isMainFrame]) {
        [self setValue:frameTitle forKey:@"title"];
    }
    [super webView:webview didReceiveTitle:frameTitle forFrame:frame];
}

- (void)webView:(id)view didStartProvisionalLoadForFrame:(id<__InnerWebFrame>)frame
{
    if ([frame isMainFrame]) {
        [self setValue:@"" forKey:@"title"];
        id value = [(id)[self innerWebView] performSelector:NSSelectorFromString([@"mainF" stringByAppendingString:@"rameURL"])];
        [self setValue:value forKey:@"URL"];
        [self willChangeValueForKey:@"canGoBack"];
        [self didChangeValueForKey:@"canGoBack"];
        [self willChangeValueForKey:@"canGoForward"];
        [self didChangeValueForKey:@"canGoForward"];
        [self willChangeValueForKey:@"loading"];
        [self didChangeValueForKey:@"loading"];
    }
    [super webView:view didStartProvisionalLoadForFrame:frame];
}

- (void)webView:(id)view didFinishLoadForFrame:(id<__InnerWebFrame>)frame
{
    if ([frame isMainFrame]) {
        id value = [(id)[self innerWebView] performSelector:NSSelectorFromString([@"mainF" stringByAppendingString:@"rameURL"])];
        [self setValue:value forKey:@"URL"];
        [self willChangeValueForKey:@"canGoBack"];
        [self didChangeValueForKey:@"canGoBack"];
        [self willChangeValueForKey:@"canGoForward"];
        [self didChangeValueForKey:@"canGoForward"];
        [self willChangeValueForKey:@"loading"];
        [self didChangeValueForKey:@"loading"];
    }
    [super webView:view didFinishLoadForFrame:frame];
}

- (void)webView:(id)view didChangeLocationWithinPageForFrame:(id<__InnerWebFrame>)frame
{
    if ([frame isMainFrame]) {
        id value = [(id)[self innerWebView] performSelector:NSSelectorFromString([@"mainF" stringByAppendingString:@"rameURL"])];
        [self setValue:value forKey:@"URL"];
        [self willChangeValueForKey:@"canGoBack"];
        [self didChangeValueForKey:@"canGoBack"];
        [self willChangeValueForKey:@"canGoForward"];
        [self didChangeValueForKey:@"canGoForward"];
        [self willChangeValueForKey:@"loading"];
        [self didChangeValueForKey:@"loading"];
    }
    [super webView:view didChangeLocationWithinPageForFrame:frame];
}

#pragma mark - message forwording

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *methodSignature = [super methodSignatureForSelector:aSelector];
    if (methodSignature == nil) {
        char *typeEncodings = NULL;
        if (aSelector == @selector(rjDynamicHack__browserView)) {
            asprintf(&typeEncodings, "%s%s%s", @encode(id), @encode(id), @encode(SEL));
        } else if (aSelector == @selector(rjDynamicHack__setDrawInWebThread:)) {
            asprintf(&typeEncodings, "%s%s%s%s", @encode(void), @encode(id), @encode(SEL), @encode(BOOL));
        }
        if (typeEncodings) {
            methodSignature = [NSMethodSignature signatureWithObjCTypes:typeEncodings];
            free(typeEncodings) ;
        }
    }
    return methodSignature;
}

- (void)forwardInvocation:(NSInvocation *)invocation
{
    SEL selector = invocation.selector;
    const char *selName = sel_getName(selector);
    const char *prefix = "rjDynamicHack_";
    if (strncmp(selName, prefix, strlen(prefix)) == 0) {
        selName = (char *)(selName + strlen(prefix));
        if (selName[0] != '\0') {
            Class cls = NSClassFromString(@"__RJUIWebView");
            SEL selector_origin = sel_registerName(selName);
            if ([self respondsToSelector:selector_origin]) {
                Method method = class_getInstanceMethod(cls, selector_origin);
                class_addMethod(cls, selector, class_getMethodImplementation(cls, selector_origin), method_getTypeEncoding(method));
                if ([self respondsToSelector:selector]) {
                    [invocation invokeWithTarget:self];
                    return;
                }
            }
        }
    }
    [super forwardInvocation:invocation];
}

@end
