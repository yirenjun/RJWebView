//
//  RJWebView.m
//  RJWebView
//
//  Created by yirenjun@gmail.com on 15/2/6.
//  Copyright © 2016年 RJ. All rights reserved.
//

#import "RJWebView.h"
#import "__RJUIWebView.h"
#import "__RJWKWebView.h"
#import <objc/runtime.h>
#import "RJWebViewLogging.h"

#define WebView ([(NSClassFromString(@"WKWebView") ? [__RJWKWebView class] : [__RJUIWebView class]) alloc])

@interface RJWebView () <RJWebViewDelegate>

@property (assign, nonatomic) BOOL classic;
@property (strong, nonatomic) UIView<RJWebViewProtocol> *innerWebView;

@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wprotocol"

@implementation RJWebView

@dynamic allowsBackForwardNavigationGestures;
@dynamic scrollView;
@dynamic allowsInlineMediaPlayback;

@synthesize URL;
@synthesize title;
@synthesize estimatedProgress;
@synthesize loading;
@synthesize canGoBack;
@synthesize canGoForward;

- (instancetype)initWithFrame:(CGRect)frame
{
    return [[super initWithFrame:frame] setup];
}

- (instancetype)initWithFrame:(CGRect)frame classic:(BOOL)classic
{
    self = [super initWithFrame:frame];
    if (self) self.classic = classic;
    return [self setup];
}

- (void)awakeFromNib
{
    [self setup];
}

static void *LocalKVOContext = &(LocalKVOContext);

- (instancetype)setup
{
    if (self) {
        [self addSubview:^(void){
            self.innerWebView = self.classic ? [[__RJUIWebView alloc] _initWithFrame:self.bounds] : [WebView _initWithFrame:self.bounds];
            self.innerWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            self.innerWebView.allowsInlineMediaPlayback = YES;
            [self.innerWebView setDelegate:_delegate ? self : nil];
            return self.innerWebView;
        }()];
        [self.innerWebView addObserver:self forKeyPath:@"URL" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial) context:LocalKVOContext];
        [self.innerWebView addObserver:self forKeyPath:@"title" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial) context:LocalKVOContext];
        [self.innerWebView addObserver:self forKeyPath:@"estimatedProgress" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial) context:LocalKVOContext];
        [self.innerWebView addObserver:self forKeyPath:@"loading" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial) context:LocalKVOContext];
        [self.innerWebView addObserver:self forKeyPath:@"canGoBack" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial) context:LocalKVOContext];
        [self.innerWebView addObserver:self forKeyPath:@"canGoForward" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionInitial) context:LocalKVOContext];
    }
    return self;
}

- (void)dealloc
{
    [self.innerWebView removeObserver:self forKeyPath:@"URL" context:LocalKVOContext];
    [self.innerWebView removeObserver:self forKeyPath:@"title" context:LocalKVOContext];
    [self.innerWebView removeObserver:self forKeyPath:@"estimatedProgress" context:LocalKVOContext];
    [self.innerWebView removeObserver:self forKeyPath:@"loading" context:LocalKVOContext];
    [self.innerWebView removeObserver:self forKeyPath:@"canGoBack" context:LocalKVOContext];
    [self.innerWebView removeObserver:self forKeyPath:@"canGoForward" context:LocalKVOContext];
    [self.innerWebView setDelegate:nil];
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if (protocol_getMethodDescription(@protocol(RJWebViewProtocol), aSelector, YES, YES).name ||
        protocol_getMethodDescription(@protocol(RJWebViewProtocol), aSelector, YES, NO).name ||
        protocol_getMethodDescription(@protocol(RJWebViewProtocol), aSelector, NO, YES).name ||
        protocol_getMethodDescription(@protocol(RJWebViewProtocol), aSelector, NO, NO).name) {
        return self.innerWebView;
    }
    return nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == LocalKVOContext) {
        id value = change[NSKeyValueChangeNewKey];
        if (value == [NSNull null])
            [self setValue:nil forKey:keyPath];
        else
            [self setValue:value forKey:keyPath];
        return;
    }
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
}

- (void)setDelegate:(id<RJWebViewDelegate>)delegate
{
    _delegate = delegate;
    [self.innerWebView setDelegate:_delegate ? self : nil];
}

#pragma mark - RJWebViewDelegate

- (BOOL)webView:(RJWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NBULogDebug(@">>> webView:shouldStartLoad:* >>> %@, %@", webView, request);
    if ([self.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)])
        return [self.delegate webView:self shouldStartLoadWithRequest:request navigationType:navigationType];
    return YES;
}

- (void)webViewDidStartLoad:(RJWebView *)webView
{
    NBULogDebug(@">>> webViewDidStartLoad: >>> %@", webView);
    if ([self.delegate respondsToSelector:@selector(webViewDidStartLoad:)])
        [self.delegate webViewDidStartLoad:self];
}

- (void)webViewDidFinishLoad:(RJWebView *)webView
{
    NBULogDebug(@">>> webViewDidFinishLoad: >>> %@", webView);
    if ([self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)])
        [self.delegate webViewDidFinishLoad:self];
}

- (void)webView:(RJWebView *)webView didFailLoadWithError:(NSError *)error
{
    NBULogError(@">>> webView:didFailLoadWithError: >>> %@, %@", webView, error);
    if ([self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)])
        [self.delegate webView:self didFailLoadWithError:error];
}

@end

#pragma clang diagnostic pop
