//
//  HAMFavoritesCollectionViewController_iPhone.h
//  BeaconReceiver
//
//  Created by daiyue on 5/5/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HAMThing;

@interface HAMFavoritesCollectionViewController_iPhone : UICollectionViewController {
    NSArray *thingArray;
    HAMThing *thingForSegue;
}

@end
