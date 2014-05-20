//
//  HAMAVManager.h
//  BeaconReceiver
//
//  Created by Dai Yue on 14-5-17.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AVOSCloud/AVOSCloud.h>
#import <CoreLocation/CoreLocation.h>

#import "HAMBeaconManager.h"

@class HAMThing;

@interface HAMAVOSManager : NSObject{}

+ (AVObject*)beaconAVObjectWithCLBeacon:(CLBeacon*)beacon;

+ (AVObject*)queryBeaconAVObjectWithCLBeacon:(CLBeacon*)beacon;
+ (HAMBeaconState)ownStateOfBeacon:(CLBeacon*)beacon;

+ (void)saveCLBeacon:(CLBeacon*)beacon;
+ (void)saveCLBeacon:(CLBeacon*)beacon withTarget:(id)target callback:(SEL)callback;

+ (HAMThing*)thingWithThingAVObject:(AVObject *)thingObject;
+ (AVObject*)thingAVObjectWithThing:(HAMThing*)thing;
+ (AVObject*)saveThing:(HAMThing*)thing;

+ (HAMThing*)thingWithBeacon:(CLBeacon*)beacon;
+ (HAMThing*)thingWithBeaconID:(NSString *)beaconID major:(NSNumber *)major minor:(NSNumber *)minor;

+ (void)unbindThingToBeacon:(CLBeacon*)beacon withTarget:(id)target callback:(SEL)callback;
+ (void)bindThing:(HAMThing*)thing range:(CLProximity)range toBeacon:(CLBeacon*)beacon withTarget:(id)target callback:(SEL)callback;

+ (AVFile*)saveImage:(UIImage*)image;

@end
