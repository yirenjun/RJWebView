//
//  __RJWKWebView.m
//  RJWebView
//
//  Created by yirenjun@gmail.com on 15/2/6.
//  Copyright © 2016年 RJ. All rights reserved.
//

#import "__RJWKWebView.h"
#import <objc/runtime.h>
#import <objc/message.h>

static UIWebViewNavigationType toClassicNavigationType(WKNavigationType type) {
    if (type == WKNavigationTypeOther)
        return UIWebViewNavigationTypeOther;
    return (UIWebViewNavigationType)type;
}

@interface __RJWKWebView (Inner)

- (void)rjDynamicHack__setCustomUserAgent:(NSString *)userAgent;
- (void)rjDynamicHack__setApplicationNameForUserAgent:(NSString *)userAgent;
- (NSString *)rjDynamicHack__userAgent;

@end

@interface __RJWKWebView () <WKNavigationDelegate>

@property (weak, nonatomic) id<RJWebViewDelegate> delegate;

@end

@implementation __RJWKWebView

@dynamic allowsBackForwardNavigationGestures;
@dynamic scrollView;

+ (WKProcessPool *)sharedProcessPool
{
    static WKProcessPool *processPool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        processPool = [WKProcessPool new];
    });
    return processPool;
}

- (instancetype)_initWithFrame:(CGRect)frame
{
    WKWebViewConfiguration *internalConfig = [[WKWebViewConfiguration alloc] init];
    internalConfig.processPool = [[self class] sharedProcessPool];
    return [self initWithFrame:frame configuration:internalConfig];
}

- (void)setDelegate:(id<RJWebViewDelegate>)delegate
{
    _delegate = delegate;
    self.navigationDelegate = _delegate ? self : nil;
}

- (void)rj_setCustomUserAgent:(NSString *)customUserAgent
{
    return [self rjDynamicHack__setCustomUserAgent:customUserAgent];
}

- (void)rj_setApplicationNameForUserAgent:(NSString *)appName
{
    [self rjDynamicHack__setApplicationNameForUserAgent:appName];
}

- (NSString *)currentUserAgent
{
    return [self rjDynamicHack__userAgent];
}

- (BOOL)allowsInlineMediaPlayback
{
    return self.configuration.allowsInlineMediaPlayback;
}

- (void)setAllowsInlineMediaPlayback:(BOOL)allowsInlineMediaPlayback
{
    self.configuration.allowsInlineMediaPlayback = allowsInlineMediaPlayback;
}

- (BOOL)mediaPlaybackRequiresUserAction
{
    if ([self.configuration respondsToSelector:@selector(requiresUserActionForMediaPlayback)])
        return self.configuration.requiresUserActionForMediaPlayback;
    return self.configuration.mediaPlaybackRequiresUserAction;
}

- (void)setMediaPlaybackRequiresUserAction:(BOOL)mediaPlaybackRequiresUserAction
{
    if ([self.configuration respondsToSelector:@selector(setRequiresUserActionForMediaPlayback:)])
        return [self.configuration setRequiresUserActionForMediaPlayback:mediaPlaybackRequiresUserAction];
    self.configuration.mediaPlaybackRequiresUserAction = mediaPlaybackRequiresUserAction;
}

- (void)setupUserScripts
{
    [self.configuration.userContentController removeAllUserScripts];
}

- (void)setupCookies:(NSArray *)cookies
{
    [self setupUserScripts];
    NSMutableString *js = @"".mutableCopy;
    for (NSHTTPCookie *cookie in cookies) {
        [js appendFormat:@"document.cookie = "];
        [js appendFormat:@"encodeURIComponent('%@') + '=' + encodeURIComponent('%@') +", cookie.name, cookie.value];
        if (cookie.expiresDate) {
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
            [dateFormatter setDateStyle:NSDateFormatterLongStyle];
            [js appendFormat:@"'; expires=%@' +", [dateFormatter stringFromDate:cookie.expiresDate]];
        }
        if (cookie.domain)
            [js appendFormat:@"'; domain=%@' +", cookie.domain];
        if (cookie.path)
            [js appendFormat:@"'; path=%@' +", cookie.path];
        if (cookie.secure)
            [js appendFormat:@"'; secure' +"];
        [js appendFormat:@"''"];
    }
    WKUserScript *cookieScript = [[WKUserScript alloc] initWithSource:js injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:NO];
    [self.configuration.userContentController addUserScript:cookieScript];
}

- (nullable NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script
{
    __block NSString *resultString = nil;
    [self evaluateJavaScript:script completionHandler:^(id result, NSError *error) {
        if (error == nil) {
            if (result) {
                resultString = [NSString stringWithFormat:@"%@", result];
            }
        } else {
            NSLog(@"evaluateJavaScript error : %@", error.localizedDescription);
        }
    }];
    
    while (resultString == nil) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    return resultString;
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    if ([self.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)]) {
        BOOL flag = [self.delegate webView:(id)self
                shouldStartLoadWithRequest:navigationAction.request
                            navigationType:toClassicNavigationType(navigationAction.navigationType)];
        decisionHandler(flag ? WKNavigationActionPolicyAllow : WKNavigationActionPolicyCancel);
        return;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    if ([self.delegate respondsToSelector:@selector(webViewDidStartLoad:)])
        [self.delegate webViewDidStartLoad:(id)self];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation
{
    if ([self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)])
        [self.delegate webViewDidFinishLoad:(id)self];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)])
        [self.delegate webView:(id)self didFailLoadWithError:error];
}

#pragma mark - message forwording

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *methodSignature = [super methodSignatureForSelector:aSelector];
    if (methodSignature == nil) {
        char *typeEncodings = NULL;
        if (aSelector == @selector(rjDynamicHack__setCustomUserAgent:)) {
            asprintf(&typeEncodings, "%s%s%s%s", @encode(void), @encode(id), @encode(SEL), @encode(NSString *));
        } else if (aSelector == @selector(rjDynamicHack__setApplicationNameForUserAgent:)) {
            asprintf(&typeEncodings, "%s%s%s%s", @encode(void), @encode(id), @encode(SEL), @encode(NSString *));
        } else if (aSelector == @selector(rjDynamicHack__userAgent)) {
            asprintf(&typeEncodings, "%s%s%s", @encode(NSString *), @encode(id), @encode(SEL));
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
            Class cls = NSClassFromString(@"__RJWKWebView");
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