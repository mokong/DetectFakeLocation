//
//  CLLocationManager+ForFakeLocationDetect.m
//  MorganWang
//
//  Created by MorganWangon 2021/8/6.
//

#import "CLLocationManager+DetectFakeLocation.h"
#import <CoreLocation/CoreLocation.h>
#import "MWFakeLocationDetectUtil.h"
#import <objc/runtime.h>

@implementation CLLocationManager (ForFakeLocationDetect)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // 交换CoreLocation中的代理方法
        Method originalMethod = class_getInstanceMethod(self, @selector(setDelegate:));
        Method exchangeMethod = class_getInstanceMethod(self, @selector(hk_setDelegate:));
        method_exchangeImplementations(originalMethod, exchangeMethod);

    });
}

- (void)hk_setDelegate:(id<CLLocationManagerDelegate>)delegate {
    [self hk_setDelegate:delegate];
    
    // 获得delegate的实际调用类
    Class aClass = [delegate class];
    // 传递给HXFakeLocationDetectUtil来交互方法
    [MWFakeLocationDetectUtil exchangeLocationMethods];
    [MWFakeLocationDetectUtil exchangeLocationDelegateMethods:aClass];
}


@end
