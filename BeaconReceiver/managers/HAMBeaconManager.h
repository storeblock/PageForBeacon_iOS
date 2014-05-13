//
//  HAMBeaconManager.h
//  BeaconReceiver
//
//  Created by daiyue on 5/10/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class HAMHomepageData;

@protocol HAMBeaconManagerDelegate <NSObject>

- (void)displayHomepage:(NSArray*)stuffsAround;

@end


@interface HAMBeaconManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, retain) id<HAMBeaconManagerDelegate> delegate;
@property (nonatomic, retain) id<HAMBeaconManagerDelegate> detailDelegate;
@property CLBeacon *nearestBeacon;
@property NSMutableDictionary *debugTextFields;

- (void)startMonitor;
- (void)stopMonitor;

+ (HAMBeaconManager*)beaconManager;
+ (void)setBackGroundStatus:(Boolean)status;

@end
