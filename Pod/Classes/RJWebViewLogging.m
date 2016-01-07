//
//  RJWebViewLogging.m
//  RJWebView
//
//  Created by yirenjun@gmail.com on 15/5/26.
//  Copyright © 2016年 RJ. All rights reserved.
//

#if __has_include("NBULog.h")

#import "RJWebViewLogging.h"
#import <NBULog/NBULogContextDescription.h>

@implementation RJWebViewLogging

+ (void)load
{
    // Register the NBUKit log context
    [NBULog registerContextDescription:[NBULogContextDescription descriptionWithName:@"RJWebView"
                                                                             context:RJWebView_LOG_CONTEXT
                                                                     modulesAndNames:nil
                                                                   contextLevelBlock:^{
                                                                       return [self ddLogLevel];
                                                                   }
                                                                setContextLevelBlock:^(DDLogLevel level) {
                                                                    [self ddSetLogLevel:level];
                                                                }
                                                          contextLevelForModuleBlock:^DDLogLevel(int module) {
                                                              return [self ddLogLevelForModule:module];
                                                          }
                                                       setContextLevelForModuleBlock:^(int module, DDLogLevel level) {
                                                           [self ddSetLogLevel:level forModule:module];
                                                       }]];
}

+ (DDLogLevel)ddLogLevel
{
    return [self ddLogLevelForModule:LOG_MODULE];
}

+ (void)ddSetLogLevel:(DDLogLevel)logLevel
{
    [self ddSetLogLevel:logLevel forModule:LOG_MODULE];
}

+ (DDLogLevel)ddLogLevelForModule:(int)module
{
    NSString *key = [NSString stringWithFormat:@"com.thinkdit.rjwebview.ddloglevel/%d", module];
    return [[[NSUserDefaults standardUserDefaults] objectForKey:key] intValue];
}

+ (void)ddSetLogLevel:(DDLogLevel)logLevel forModule:(int)module
{
    NSString *key = [NSString stringWithFormat:@"com.thinkdit.rjwebview.ddloglevel/%d", module];
    [[NSUserDefaults standardUserDefaults] setObject:@(logLevel) forKey:key];
}

@end

#endif
