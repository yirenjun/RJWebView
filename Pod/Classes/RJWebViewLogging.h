//
//  RJWebViewLogging.h
//  RJWebView
//
//  Created by yirenjun@gmail.com on 15/5/26.
//  Copyright © 2016年 RJ. All rights reserved.
//

#ifndef Pods_RJWebViewLogging_h
#define Pods_RJWebViewLogging_h

// a) Use NBULog for logging when available
#if __has_include("NBULog.h")

#import <NBULog/NBULog.h>

#undef  LOG_CONTEXT
#define LOG_CONTEXT RJWebView_LOG_CONTEXT

#undef  LOG_MODULE
#define LOG_MODULE  APP_MODULE_DEFAULT

#undef  LOG_LEVEL
#define LOG_LEVEL   [RJWebViewLogging ddLogLevelForModule:LOG_MODULE]

#undef  LOG_LEVEL_FOR_MODULE
#define LOG_LEVEL_FOR_MODULE(mod) [RJWebViewLogging ddLogLevelForModule:mod]

// RJWebView log context
#define RJWebView_LOG_CONTEXT 315

// RJWebView modules

@interface RJWebViewLogging : NSObject  <DDRegisteredDynamicLogging>

+ (DDLogLevel)ddLogLevel;
+ (void)ddSetLogLevel:(DDLogLevel)logLevel;

+ (DDLogLevel)ddLogLevelForModule:(int)module;
+ (void)ddSetLogLevel:(DDLogLevel)logLevel forModule:(int)module;

@end

// b) Else try CocoaLumberjack
#elif __has_include("DDLog.h")

#ifdef DEBUG
#define RJWebViewLogLevel DDLogLevelVerbose
#else
#define RJWebViewLogLevel DDLogLevelWarning
#endif

#define LOG_LEVEL_DEF RJWebViewLogLevel
#import <CocoaLumberjack/DDLog.h>

#define NBULogError(frmt, ...)      DDLogError(frmt, ##__VA_ARGS__)
#define NBULogWarn(frmt, ...)       DDLogWarn(frmt, ##__VA_ARGS__)
#define NBULogInfo(frmt, ...)       DDLogInfo(frmt, ##__VA_ARGS__)
#define NBULogDebug(frmt, ...)      DDLogDebug(frmt, ##__VA_ARGS__)
#define NBULogVerbose(frmt, ...)    DDLogVerbose(frmt, ##__VA_ARGS__)
#define NBULogTrace()               NBULogDebug(@"%@", THIS_METHOD)

// c) Else fallback to NSLog
#else

#ifdef DEBUG
#define LOG_LEVEL 4
#else
#define LOG_LEVEL 0
#endif

#define THIS_METHOD                 NSStringFromSelector(_cmd)
#define NBULogError(frmt, ...)      do{ if(LOG_LEVEL >= 1) NSLog((frmt), ##__VA_ARGS__); } while(0)
#define NBULogWarn(frmt, ...)       do{ if(LOG_LEVEL >= 2) NSLog((frmt), ##__VA_ARGS__); } while(0)
#define NBULogInfo(frmt, ...)       do{ if(LOG_LEVEL >= 3) NSLog((frmt), ##__VA_ARGS__); } while(0)
#define NBULogDebug(frmt, ...)      do{ if(LOG_LEVEL >= 4) NSLog((frmt), ##__VA_ARGS__); } while(0)
#define NBULogVerbose(frmt, ...)    do{ if(LOG_LEVEL >= 5) NSLog((frmt), ##__VA_ARGS__); } while(0)
#define NBULogTrace()               NBULogDebug(@"%@", THIS_METHOD)

#endif


#endif
