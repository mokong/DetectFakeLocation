//
//  HXFakeLocationDetectUtil.m
//  MorganWang
//
//  Created by MorganWangon 2021/8/6.
//  Copyright © 2021 MorganWang. All rights reserved.
//

#import "MWFakeLocationDetectUtil.h"
#import <objc/runtime.h>

@interface MWFakeLocationDetectUtil ()

@property (nonatomic, assign) NSInteger requestCount; // 回调次数
@property (nonatomic, assign) BOOL isSuspecious; // 是否可疑
@property (nonatomic, assign) BOOL isSuspeciousJail; // 越狱检测
@property (nonatomic, assign) BOOL isSuspeciousAltitue; // 根据海拔和海拔精度检测
@property (nonatomic, assign) BOOL isSuspeciousCallbackCount; // 根据回调位置检测
@property (nonatomic, assign) BOOL isSuspeciousType; // 根据定位类型检测
@property (nonatomic, strong) CLLocation *location;

@end

@implementation MWFakeLocationDetectUtil

+ (void)exchangeLocationDelegateMethods:(Class)aClass {
    // locationManager:didUpdateLocations: 是CLLocationManagerDelegate的方法，所以originalClass是传入的delegate
    hook_exchangeMethod(aClass, @selector(locationManager:didUpdateLocations:),
                        [self class], @selector(hx_locationManager:didUpdateLocations:));
}

+ (void)exchangeLocationMethods {
    // startUpdatingLocation 是 CLLocationManager的方法，所以originalClass是[CLLocationManager class]
    hook_exchangeMethod([CLLocationManager class], @selector(startUpdatingLocation),
                        [self class], @selector(hx_startUpdatingLocation));
}

static void hook_exchangeMethod(Class originalClass, SEL originalSel, Class replacedClass, SEL replacedSel){
    Method originalMethod = class_getInstanceMethod(originalClass, originalSel);
    Method replacedMethod = class_getInstanceMethod(replacedClass, replacedSel);
    IMP replacedMethodIMP = method_getImplementation(replacedMethod);
    // 将样替换的方法往代理类中添加, (一般都能添加成功, 因为代理类中不会有我们自定义的函数)
    BOOL didAddMethod =
    class_addMethod(originalClass,
                    replacedSel,
                    replacedMethodIMP,
                    method_getTypeEncoding(replacedMethod));

    if (didAddMethod) {// 添加成功
        NSLog(@"class_addMethod succeed --> (%@)", NSStringFromSelector(replacedSel));
        // 获取新方法在代理类中的地址
        Method newMethod = class_getInstanceMethod(originalClass, replacedSel);
        // 交互原方法和自定义方法
        method_exchangeImplementations(originalMethod, newMethod);
    }else{// 如果失败, 则证明自定义方法在代理方法中, 直接交互就可以
        method_exchangeImplementations(originalMethod, replacedMethod);
    }
}

+ (instancetype)util {
    static dispatch_once_t onceToken;
    static MWFakeLocationDetectUtil *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.isSuspeciousJail = [MWFakeLocationDetectUtil isJailedDevice];
        self.isSuspeciousAltitue = NO;
        self.isSuspeciousCallbackCount = NO;
        self.isSuspeciousType = NO;
        self.location = nil;
    }
    return self;
}

- (BOOL)isSuspecious {
    MWFakeLocationDetectUtil *util = [MWFakeLocationDetectUtil util];
    return util.isSuspeciousAltitue && util.isSuspeciousType;
//    return util.isSuspeciousJail ||
//        util.isSuspeciousAltitue ||
//      util.isSuspeciousCallbackCount ||
//        util.isSuspeciousType;
}

- (void)hx_startUpdatingLocation {
    [self hx_startUpdatingLocation];

    MWFakeLocationDetectUtil *util = [MWFakeLocationDetectUtil util];
    util.requestCount = 0;
    util.isSuspeciousAltitue = NO;
    util.isSuspeciousCallbackCount = NO;
    util.isSuspeciousType = NO;
    util.location = nil;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_global_queue(0, 0), ^{
        [util checkCallbackCount];
        [util checkLocationAltitudeAccuracy:util.location];
        [util checkLocationType:util.location];
        [util reportSuspicousLocation];
    });
}

- (void)hx_locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    [self hx_locationManager:manager
          didUpdateLocations:locations];
    
    CLLocation *location = [locations lastObject];

    MWFakeLocationDetectUtil *util = [MWFakeLocationDetectUtil util];
    util.requestCount += 1;
    util.location = location;
}

/// 上报虚假
- (void)reportSuspicousLocation {
    MWFakeLocationDetectUtil *util = [MWFakeLocationDetectUtil util];
    NSLog(@"isSuspeciousJail: %d, isSuspeciousCallbackCount :%d, isSuspeciousAltitue: %d, isSuspeciousType: %d", util.isSuspeciousJail, util.isSuspeciousCallbackCount, util.isSuspeciousAltitue, util.isSuspeciousType);
    BOOL isSuspicousLocation = util.isSuspecious;
    if (isSuspicousLocation) {
        NSLog(@"可疑位置--------------");
    }
    else {
        NSLog(@"正常定位--------------");
    }
    if (util.resultCallback) {
        util.resultCallback(isSuspicousLocation);
    }
}

/// 根据回调次数判断是否是虚假定位
- (void)checkCallbackCount {
    MWFakeLocationDetectUtil *util = [MWFakeLocationDetectUtil util];
    if (util.requestCount == 1) {
        util.isSuspeciousCallbackCount = YES;
    }
}

/// 定位海拔、海拔垂直精度
/// @param location 定位Item
- (void)checkLocationAltitudeAccuracy:(CLLocation *)location {
//    NSLog(@"海拔高度：%f", location.altitude);
//    NSLog(@"海拔垂直精度：%f", location.verticalAccuracy);
    MWFakeLocationDetectUtil *util = [MWFakeLocationDetectUtil util];
    if ((location.altitude == 0.0) && (location.verticalAccuracy == -1.0)) {
        util.isSuspeciousAltitue = YES;
    }
}

/// 根据type判断
/// @param location 定位Item
- (void)checkLocationType:(CLLocation *)location {
    MWFakeLocationDetectUtil *util = [MWFakeLocationDetectUtil util];
    NSString *type = [location valueForKey:@"type"];
    if (type) {
        if ((type.integerValue == 1) || (type.integerValue == 3)) {
            util.isSuspeciousType = YES;
        }
    }
}

/// 判断是否是越狱设备
+ (BOOL)isJailedDevice {
    NSString *appPathStr = @"/User/Applications";
    if ([[NSFileManager defaultManager] fileExistsAtPath:appPathStr]) {
        NSError *error;
        NSArray *appList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:appPathStr error:&error];
        if ((!error) && (appList != nil) && (appList.count > 0)) {
            return YES;
        }
        else {
            return NO;
        }
    }
    else {
        return NO;
    }
}

@end
