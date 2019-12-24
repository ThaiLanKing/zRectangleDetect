//
//  UtilsMacros.h
//  JamBoHealth
//
//  Created by zyh on 17/6/27.
//  Copyright © 2017年 zyh. All rights reserved.
//

/**
 * 全局工具类宏定义
 * 主要存放一些跟具体App无关、任何App都可以使用的通用性宏定义
 */

#ifndef UtilsMacros_h
#define UtilsMacros_h

#ifndef DEBUG

#define NSLog(...)

#endif

#pragma mark - 获取系统对象

#define kApplication        [UIApplication sharedApplication]
#define kAppWindow          [UIApplication sharedApplication].delegate.window
#define kAppDelegate        [AppDelegate shareAppDelegate]
#define kStandardUserDefaults       [NSUserDefaults standardUserDefaults]
#define kDefaultNotificationCenter [NSNotificationCenter defaultCenter]

#pragma mark - 部分界面属性

#define kScreenBounds     ([UIScreen mainScreen].bounds)
#define kScreenBoundsSize (kScreenBounds.size)
#define kScreenWidth      (kScreenBoundsSize.width)
#define kScreenHeight     (kScreenBoundsSize.height)
#define kStatusBarH       ([UIApplication sharedApplication].statusBarFrame.size.height)

#pragma mark - 强弱引用
//RAC的@weakify有个优势：可以同时操作多个对象，如@weakify(obj1, obj2),而如下定义不行
#define KWeakify(type)   __weak typeof(type) weak##type = type;
#define KStrongify(type) __strong typeof(type) type = weak##type;

#pragma mark - GCD

#ifndef dispatch_main_async_safe
#define dispatch_main_async_safe(block) dispatch_queue_async_safe(dispatch_get_main_queue(), block)
#endif

#pragma mark - 发送通知
//带参数的用K开头，不带参的用k开头
#define kNotificationCenter ([NSNotificationCenter defaultCenter])
#define KPostNotification(name, obj) ([kNotificationCenter postNotificationName:name object:obj])

#pragma mark - 系统版本号判断

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


#ifndef    weakify
#if __has_feature(objc_arc)

#define weakify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
autoreleasepool{} __weak __typeof__(x) __weak_##x##__ = x; \
_Pragma("clang diagnostic pop")

#else

#define weakify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
autoreleasepool{} __block __typeof__(x) __block_##x##__ = x; \
_Pragma("clang diagnostic pop")

#endif
#endif

#ifndef    strongify
#if __has_feature(objc_arc)

#define strongify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
try{} @finally{} __typeof__(x) x = __weak_##x##__; \
_Pragma("clang diagnostic pop")

#else

#define strongify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
try{} @finally{} __typeof__(x) x = __block_##x##__; \
_Pragma("clang diagnostic pop")

#endif
#endif

#endif /* UtilsMacros_h */
