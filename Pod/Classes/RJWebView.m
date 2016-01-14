//
//  RJWebView.m
//  RJWebView
//
//  Created by yirenjun@gmail.com on 15/2/6.
//  Copyright © 2016年 RJ. All rights reserved.
//

#import "RJWebView.h"
#import "__RJInternalWebViewProtocol.h"
#import "__RJUIWebView.h"
#import "__RJWKWebView.h"

@interface RJWebView () <RJWebViewDelegate>

@property (strong, nonatomic) UIView<__RJInternalWebViewProtocol> *innerWebView;

@end

@implementation RJWebView

@synthesize URL;
@synthesize title;
@synthesize estimatedProgress;
@synthesize loading;
@synthesize canGoBack;
@synthesize canGoForward;

static void *LocalKVOContext = &(LocalKVOContext);

- (instancetype _Null_unspecified)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _needsToUseWK = false;
    }
    return [self setup];
}

- (instancetype _Null_unspecified)initWithFrame:(CGRect)frame withWK:(BOOL)needsToUseWK {
    self = [super initWithFrame:frame];
    if (self) {
        _needsToUseWK = needsToUseWK;
    }
    return [self setup];
}

- (void)awakeFromNib {
    [self setup];
}

- (instancetype)setup {
    if (self) {
        [self addSubview:^(void){
            self.innerWebView = (self.needsToUseWK && NSClassFromString(@"WKWebView"))
            ? [[__RJWKWebView alloc] initWithFrame:self.bounds]
            : [[__RJUIWebView alloc] initWithFrame:self.bounds];
            self.innerWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
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

- (void)dealloc {
    [self.innerWebView removeObserver:self forKeyPath:@"URL" context:LocalKVOContext];
    [self.innerWebView removeObserver:self forKeyPath:@"title" context:LocalKVOContext];
    [self.innerWebView removeObserver:self forKeyPath:@"estimatedProgress" context:LocalKVOContext];
    [self.innerWebView removeObserver:self forKeyPath:@"loading" context:LocalKVOContext];
    [self.innerWebView removeObserver:self forKeyPath:@"canGoBack" context:LocalKVOContext];
    [self.innerWebView removeObserver:self forKeyPath:@"canGoForward" context:LocalKVOContext];
    [self.innerWebView setDelegate:nil];
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

- (void)setDelegate:(id<RJWebViewDelegate>)delegate {
    _delegate = delegate;
    [self.innerWebView setDelegate:_delegate ? self : nil];
}

- (UIScrollView *)scrollView {
    return [self.innerWebView scrollView];
}

- (BOOL)allowsBackForwardNavigationGestures {
    return self.innerWebView.allowsBackForwardNavigationGestures;
}

- (void)setAllowsBackForwardNavigationGestures:(BOOL)allowsBackForwardNavigationGestures {
    self.innerWebView.allowsBackForwardNavigationGestures = allowsBackForwardNavigationGestures;
}

- (BOOL)allowsInlineMediaPlayback {
    return self.innerWebView.allowsInlineMediaPlayback;
}

- (void)setAllowsInlineMediaPlayback:(BOOL)allowsInlineMediaPlayback {
    [self.innerWebView setAllowsInlineMediaPlayback:allowsInlineMediaPlayback];
}

- (BOOL)mediaPlaybackRequiresUserAction {
    return self.innerWebView.mediaPlaybackRequiresUserAction;
}

- (void)setMediaPlaybackRequiresUserAction:(BOOL)mediaPlaybackRequiresUserAction {
    return [self.innerWebView setMediaPlaybackRequiresUserAction:mediaPlaybackRequiresUserAction];
}

- (NSString * _Nullable)currentUserAgent {
    return [self.innerWebView currentUserAgent];
}

- (void)setCustomUserAgent:(NSString * _Nullable)userAgent {
    [self.innerWebView setCustomUserAgent:userAgent];
}

- (void)setApplicationNameForUserAgent:(NSString * _Nullable)appName {
    [self.innerWebView setApplicationNameForUserAgent:appName];
}

- (void)loadRequest:(NSURLRequest * _Nonnull)request {
    [self.innerWebView loadRequest:request];
}

- (void)loadHTMLString:(NSString *_Nonnull)string baseURL:(NSURL *_Nonnull)baseURL {
    [self.innerWebView loadHTMLString:string baseURL:baseURL];
}

- (void)stopLoading {
    [self.innerWebView stopLoading];
}

- (void)reload {
    [self.innerWebView reload];
}

- (void)goBack {
    [self.innerWebView goBack];
}

- (void)goForward {
    [self.innerWebView goForward];
}

- (nullable NSString *)stringByEvaluatingJavaScriptFromString:(NSString * _Nonnull)script {
    return [self.innerWebView stringByEvaluatingJavaScriptFromString:script];
}

- (void)evaluateJavaScript:(NSString *_Nonnull)javaScriptString completionHandler:(void (^ _Nullable)(id _Nullable, NSError * _Nullable))completionHandler {
    [self.innerWebView evaluateJavaScript:javaScriptString completionHandler:completionHandler];
}

#pragma mark - RJWebViewDelegate

- (BOOL)webView:(RJWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSLog(@"RJWebView >>> webView:shouldStartLoad:* >>> %@, %@", webView, request);
    if ([self.delegate respondsToSelector:@selector(webView:shouldStartLoadWithRequest:navigationType:)])
        return [self.delegate webView:self shouldStartLoadWithRequest:request navigationType:navigationType];
    return YES;
}

- (void)webViewDidStartLoad:(RJWebView *)webView
{
    NSLog(@"RJWebView >>> webViewDidStartLoad: >>> %@", webView);
    if ([self.delegate respondsToSelector:@selector(webViewDidStartLoad:)])
        [self.delegate webViewDidStartLoad:self];
}

- (void)webViewDidFinishLoad:(RJWebView *)webView
{
    NSLog(@"RJWebView >>> webViewDidFinishLoad: >>> %@", webView);
    if ([self.delegate respondsToSelector:@selector(webViewDidFinishLoad:)])
        [self.delegate webViewDidFinishLoad:self];
}

- (void)webView:(RJWebView *)webView didFailLoadWithError:(NSError *)error
{
    NSLog(@"RJWebView >>> webView:didFailLoadWithError: >>> %@, %@", webView, error);
    if ([self.delegate respondsToSelector:@selector(webView:didFailLoadWithError:)])
        [self.delegate webView:self didFailLoadWithError:error];
}

@end
