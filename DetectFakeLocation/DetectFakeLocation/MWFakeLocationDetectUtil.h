//
//  MWFakeLocationDetectUtil.h
//  MorganWang
//
//  Created by MorganWangon 2021/8/6.
//  Copyright © 2021 MorganWang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface MWFakeLocationDetectUtil : NSObject

+ (instancetype)util;
@property (nonatomic, copy) void(^ resultCallback)(BOOL isSuspecious);

+ (void)exchangeLocationDelegateMethods:(Class)aClass;
+ (void)exchangeLocationMethods;

@end

