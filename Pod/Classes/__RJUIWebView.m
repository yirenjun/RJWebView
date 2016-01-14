//
//  __RJUIWebView.m
//  RJWebView
//
//  Created by yirenjun@gmail.com on 15/2/6.
//  Copyright © 2016年 RJ. All rights reserved.
//

#import "__RJUIWebView.h"
#import "__RJInnerBrowserView.h"
#import "__RJInnerWebFrame.h"

#import <objc/runtime.h>
#import <objc/message.h>

#pragma mark - UIWebView+rj_private

@interface UIWebView (rj_private)

- (void)rj_private__setDrawInWebThread:(BOOL)webThread;

- (id<__RJInnerBrowserView>)rj_private__browserView;

- (void)webView:(id)webview didReceiveTitle:(NSString *)title forFrame:(id<__RJInnerWebFrame>)frame;
- (void)webView:(id)view didStartProvisionalLoadForFrame:(id<__RJInnerWebFrame>)frame;
- (void)webView:(id)view didFinishLoadForFrame:(id<__RJInnerWebFrame>)frame;
- (void)webView:(id)view didChangeLocationWithinPageForFrame:(id<__RJInnerWebFrame>)frame;

@end

#pragma mark - __RJUIWebView

@implementation __RJUIWebView

@synthesize allowsBackForwardNavigationGestures;

@synthesize URL;
@synthesize title;
@synthesize estimatedProgress;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self rj_private__setDrawInWebThread:YES];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(webProgressEstimateChanged:) name:@"WebProgressEstimateChangedNotification" object:[self innerWebView]];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"WebProgressEstimateChangedNotification" object:[self innerWebView]];
}

- (void)webProgressEstimateChanged:(NSNotification *)note {
    id value = [note.userInfo objectForKey:@"WebProgressEstimatedProgressKey"];
    if (value != nil)
        [self setValue:value forKey:@"estimatedProgress"];
}

- (NSString *)currentUserAgent {
    return [[self innerWebView] userAgentForURL:nil];
}

- (void)setCustomUserAgent:(NSString *)userAgent {
    [[self innerWebView] setCustomUserAgent:userAgent];
}

- (void)setApplicationNameForUserAgent:(NSString *)appName {
    [[[self rj_private__browserView] webView] setApplicationNameForUserAgent:appName];
}

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^)(id, NSError *))completionHandler {
    NSString *string = [self stringByEvaluatingJavaScriptFromString:javaScriptString];
    if (completionHandler)
        completionHandler(string, nil);
}

#pragma mark - helper

- (id<__RJInnerWebView>)innerWebView {
    return [[self rj_private__browserView] webView];
}

- (NSURL *)mainFrameURLForInnerWebView {
    SEL selector = NSSelectorFromString([@"mainF" stringByAppendingString:@"rameURL"]);
    return ((NSURL *(*)(id, SEL))[self methodForSelector:selector])(self, selector);
}

#pragma mark - override 

- (void)webView:(id)webview didReceiveTitle:(NSString *)frameTitle forFrame:(id<__RJInnerWebFrame>)frame {
    if ([frame isMainFrame])
        [self setValue:frameTitle forKey:@"title"];
    [super webView:webview didReceiveTitle:frameTitle forFrame:frame];
}

- (void)webView:(id)view didStartProvisionalLoadForFrame:(id<__RJInnerWebFrame>)frame {
    if ([frame isMainFrame]) {
        [self setValue:@"" forKey:@"title"];
        [self setValue:[self mainFrameURLForInnerWebView] forKey:@"URL"];
        [self willChangeValueForKey:@"canGoBack"];
        [self didChangeValueForKey:@"canGoBack"];
        [self willChangeValueForKey:@"canGoForward"];
        [self didChangeValueForKey:@"canGoForward"];
        [self willChangeValueForKey:@"loading"];
        [self didChangeValueForKey:@"loading"];
    }
    [super webView:view didStartProvisionalLoadForFrame:frame];
}

- (void)webView:(id)view didFinishLoadForFrame:(id<__RJInnerWebFrame>)frame {
    if ([frame isMainFrame]) {
        [self setValue:[self mainFrameURLForInnerWebView] forKey:@"URL"];
        [self willChangeValueForKey:@"canGoBack"];
        [self didChangeValueForKey:@"canGoBack"];
        [self willChangeValueForKey:@"canGoForward"];
        [self didChangeValueForKey:@"canGoForward"];
        [self willChangeValueForKey:@"loading"];
        [self didChangeValueForKey:@"loading"];
    }
    [super webView:view didFinishLoadForFrame:frame];
}

- (void)webView:(id)view didChangeLocationWithinPageForFrame:(id<__RJInnerWebFrame>)frame {
    if ([frame isMainFrame]) {
        [self setValue:[self mainFrameURLForInnerWebView] forKey:@"URL"];
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
        if (aSelector == @selector(rj_private__browserView)) {
            asprintf(&typeEncodings, "%s%s%s", @encode(id), @encode(id), @encode(SEL));
        } else if (aSelector == @selector(rj_private__setDrawInWebThread:)) {
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
    const char *prefix = "rj_private_";
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
