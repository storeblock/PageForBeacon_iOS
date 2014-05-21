//
//  HAMAVManager.m
//  BeaconReceiver
//
//  Created by Dai Yue on 14-5-17.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import "HAMAVOSManager.h"

#import "HAMThing.h"

#import "HAMLogTool.h"

@implementation HAMAVOSManager

#pragma mark - Beacon

#pragma mark - Beacon Conversion

+ (AVObject*)beaconAVObjectWithCLBeacon:(CLBeacon*)beacon{
    if (beacon == nil) {
        return nil;
    }
    
    AVObject* beaconObject = [AVObject objectWithClassName:@"Beacon"];
    [beaconObject setObject:beacon.proximityUUID.UUIDString forKey:@"proximityUUID"];
    [beaconObject setObject:beacon.major forKey:@"major"];
    [beaconObject setObject:beacon.minor forKey:@"minor"];
    return beaconObject;
}

#pragma mark - Beacon Query

+ (AVObject*)queryBeaconAVObjectWithCLBeacon:(CLBeacon*)beacon{
    if (beacon == nil) {
        return nil;
    }
    
    AVQuery *query = [AVQuery queryWithClassName:@"Beacon"];
    [query whereKey:@"proximityUUID" equalTo:beacon.proximityUUID.UUIDString];
    [query whereKey:@"major" equalTo:beacon.major];
    [query whereKey:@"minor" equalTo:beacon.minor];
    
    NSArray* beaconArray = [query findObjects];
    if (beaconArray == nil || beaconArray.count == 0) {
        return nil;
    }
    return beaconArray[0];
}

+ (HAMBeaconState)ownStateOfBeacon:(CLBeacon*)beacon{
    if (beacon == nil) {
        [HAMLogTool warn:@"query own state of beacon nil"];
        return HAMBeaconStateOwnedByOthers;
    }
    
    HAMThing* thing = [self thingWithBeacon:beacon];
    
    if (thing.creator == nil) {
        return HAMBeaconStateFree;
    }
    
    AVUser* owner = thing.creator;
    AVUser* currentUser = [AVUser currentUser];
    if ([owner.objectId isEqualToString:currentUser.objectId]) {
        return HAMBeaconStateOwnedByMe;
    }
    return HAMBeaconStateOwnedByOthers;
}

+ (CLProximity)rangeOfBeacon:(CLBeacon*)beacon{
    if (beacon == nil) {
        [HAMLogTool warn:@"query range of beacon nil"];
        return CLProximityUnknown;
    }
    
    AVObject* beaconObject = [self queryBeaconAVObjectWithCLBeacon:beacon];
    NSString* rangeString = [beaconObject objectForKey:@"range"];
    
    if (rangeString == nil) {
        return CLProximityImmediate;
    }
    if ([rangeString isEqualToString:@"immediate"]) {
        return CLProximityImmediate;
    }
    if ([rangeString isEqualToString:@"near"]) {
        return CLProximityNear;
    }
    if ([rangeString isEqualToString:@"far"]) {
        return CLProximityFar;
    }
    
    [HAMLogTool warn:@"range of beacon unknown"];
    return CLProximityUnknown;
}

#pragma mark - Beacon Save

+ (void)saveCLBeacon:(CLBeacon*)beacon{
    if (beacon == nil) {
        [HAMLogTool warn:@"trying to save beacon nil"];
        return;
    }
    
    AVObject* beaconObject = [self beaconAVObjectWithCLBeacon:beacon];
    [beaconObject save];
}

+ (void)saveCLBeacon:(CLBeacon*)beacon withTarget:(id)target callback:(SEL)callback{
    if (beacon == nil) {
        [HAMLogTool warn:@"trying to save beacon nil"];
        return;
    }
    
    AVObject* beaconObject = [self beaconAVObjectWithCLBeacon:beacon];
    [beaconObject saveInBackgroundWithTarget:target selector:callback];
}

#pragma mark - Thing

#pragma mark - Thing Conversion

+ (HAMThing*)thingWithThingAVObject:(AVObject *)thingObject{
    if (thingObject == nil) {
        return nil;
    }
    
    HAMThing* thing = [[HAMThing alloc] init];
    
    thing.objectID = thingObject.objectId;
    
    NSString* typeString = [thingObject objectForKey:@"type"];
    [thing setTypeWithTypeString:typeString];
    thing.url = [thingObject objectForKey:@"url"];
    thing.title = [thingObject objectForKey:@"title"];
    thing.content = [thingObject objectForKey:@"content"];
    thing.coverFile = [thingObject objectForKey:@"cover"];
    thing.cover = nil;
    thing.coverURL = [thingObject objectForKey:@"coverURL"];
    thing.creator = [thingObject objectForKey:@"creator"];
    
    return thing;
}

+ (AVObject*)thingAVObjectWithThing:(HAMThing*)thing shouldSaveCover:(Boolean)shouldSaveCover{
    if (thing == nil) {
        return nil;
    }
    
    AVObject* thingObject = [AVObject objectWithClassName:@"Thing"];
    
    if (thing.objectID != nil) {
        thingObject.objectId = thing.objectID;
    }
    
    NSString* typeString = [thing typeString];
    [thingObject setObject:typeString forKey:@"type"];
    [thingObject setObject:thing.url forKey:@"url"];
    [thingObject setObject:thing.title forKey:@"title"];
    [thingObject setObject:thing.content forKey:@"content"];
    
    if (shouldSaveCover) {
        AVFile* coverFile = [self saveImage:thing.cover];
        if (coverFile != nil) {
            [thingObject setObject:coverFile forKey:@"cover"];
            [thingObject setObject:coverFile.url forKey:@"coverURL"];
        }
    } else {
        [thingObject setObject:thing.coverFile forKey:@"cover"];
        [thingObject setObject:thing.coverURL forKey:@"coverURL"];
    }
    
    [thingObject setObject:thing.creator forKey:@"creator"];

    return thingObject;
}

#pragma mark - Thing Query

+ (AVObject*)thingAVObjectWithObjectID:(NSString*)objectID{
    if (objectID == nil) {
        [HAMLogTool warn:@"query thing with objectID nil"];
        return nil;
    }
    
    AVQuery* query = [AVQuery queryWithClassName:@"Thing"];
    return [query getObjectWithId:objectID];
}

+ (HAMThing*)thingWithObjectID:(NSString*)objectID{
    AVObject* thingObject = [self thingAVObjectWithObjectID:objectID];
    if (!thingObject) {
        [HAMLogTool warn:@"thing with ObjectID not found"];
        return nil;
    }
    
    return [self thingWithThingAVObject:thingObject];
}

+ (NSArray*)thingsOfCurrentUser{
    AVUser* user = [AVUser currentUser];
    if (user == nil) {
        return nil;
    }
    
    AVQuery* query = [AVQuery queryWithClassName:@"Thing"];
    [query whereKey:@"creator" equalTo:user];
    NSArray* thingObjectArray = [query findObjects];
    
    if (thingObjectArray == nil || thingObjectArray.count == 0) {
        return @[];
    }
    
    NSMutableArray* thingArray = [NSMutableArray array];
    for (int i = 0; i < thingObjectArray.count; i++) {
        AVObject* thingObject = thingObjectArray[i];
        HAMThing* thing = [self thingWithThingAVObject:thingObject];
        [thingArray addObject:thing];
    }
    return thingArray;
}

#pragma mark - Thing Save

+ (AVObject*)saveThing:(HAMThing*)thing{
    if (thing == nil) {
        [HAMLogTool warn:@"trying to save thing nil"];
        return nil;
    }
    
    AVObject* thingObject = [self thingAVObjectWithThing:thing shouldSaveCover:YES];
    [thingObject save];
    return thingObject;
}

#pragma mark - Thing & Beacon

#pragma mark - Thing & Beacon Query

+ (HAMThing*)thingWithBeacon:(CLBeacon*)beacon{
    if (beacon == nil) {
        return nil;
    }
    
    NSString* uuid = beacon.proximityUUID.UUIDString;
    NSNumber* major = beacon.major;
    NSNumber* minor = beacon.minor;
    
    return [self thingWithBeaconID:uuid major:major minor:minor];
}

+ (HAMThing*)thingWithBeaconID:(NSString *)beaconID major:(NSNumber *)major minor:(NSNumber *)minor{
    AVQuery *query = [AVQuery queryWithClassName:@"Beacon"];
    query.cachePolicy = kPFCachePolicyNetworkElseCache;
    [query includeKey:@"thing"];
    
    [query whereKey:@"proximityUUID" equalTo:beaconID];
    [query whereKey:@"major" equalTo:major];
    [query whereKey:@"minor" equalTo:minor];
    
    AVObject* beaconObject = [query getFirstObject];
    
    if (beaconObject == nil) {
        return nil;
    }
    
    AVObject *thingObject = [beaconObject objectForKey:@"thing"];
    
    return [self thingWithThingAVObject:thingObject];
}

#pragma mark - Thing & Beacon Save

+ (void)unbindThingToBeacon:(CLBeacon*)beacon withTarget:(id)target callback:(SEL)callback{
    if (beacon == nil) {
        return;
    }
    
    AVObject* beaconObject = [self queryBeaconAVObjectWithCLBeacon:beacon];
    if (beaconObject == nil) {
        //unbind thing from unrecorded beacon, normally won't happen
        [HAMLogTool warn:@"unbind thing from unrecorded beacon."];
        return;
    }
    
    [beaconObject setObject:nil forKey:@"thing"];
    [beaconObject saveInBackgroundWithTarget:target selector:callback];
}

+ (void)bindThing:(HAMThing *)thing range:(CLProximity)range toBeacon:(CLBeacon *)beacon withTarget:(id)target callback:(SEL)callback{
    NSArray* params = [NSArray arrayWithObjects:thing, [NSNumber numberWithInt:range], beacon, target, NSStringFromSelector(callback), nil];
    [NSThread detachNewThreadSelector:@selector(bindThingSyncWithParams:) toTarget:self withObject:params];
}

+ (void)bindThingSyncWithParams:(NSArray*)params{
    //    if (![HAMTools isWebAvailable]) {
    //        return;
    //    }
    
    HAMThing* thing = params[0];
    CLProximity range = [params[1] intValue];
    CLBeacon* beacon = params[2];
    id target = params[3];
    SEL callback = NSSelectorFromString(params[4]);
    
    if (thing == nil) {
        [HAMLogTool warn:@"binding nil thing to Beacon"];
        [self unbindThingToBeacon:beacon withTarget:target callback:callback];
        return;
    }
    
    AVObject* beaconObject = [self queryBeaconAVObjectWithCLBeacon:beacon];
    
    if (beaconObject == nil) {
        //beacon not recorded. save beacon first.
        beaconObject = [self beaconAVObjectWithCLBeacon:beacon];
    }
    
    //save thing
    AVObject* thingObject = [self saveThing:thing];
    
    NSString* rangeString;
    switch (range) {
        case CLProximityImmediate:
            rangeString = @"immediate";
            break;
            
        case CLProximityNear:
            rangeString = @"near";
            break;
            
        case CLProximityFar:
            rangeString = @"far";
            break;
            
        default:
            rangeString = @"immediate";
            break;
    }
    [beaconObject setObject:rangeString forKey:@"range"];
    [beaconObject setObject:thingObject forKey:@"thing"];
    [beaconObject saveInBackgroundWithTarget:target selector:callback];
}

#pragma mark - Thing & User

#pragma mark - Thing & User Update

+ (void)updateCurrentUserCardWithName:(NSString*)name intro:(NSString*)intro{
    AVUser* user = [AVUser currentUser];
    
    NSString* cardID = [user objectForKey:@"card"];
    if (cardID == nil) {
        [HAMLogTool warn:@"Card not exists for current user"];
        return;
    }
    
    AVObject* thingObject = [self thingAVObjectWithObjectID:cardID];
    [thingObject setObject:name forKey:@"title"];
    [thingObject setObject:intro forKey:@"intro"];
    [thingObject save];
}

#pragma mark - Thing & User Save

+ (void)saveCurrentUserCard:(HAMThing*)thing{
    thing.type = HAMThingTypeCard;
    AVObject* thingObject = [self saveThing:thing];
    
    AVUser* user = [AVUser currentUser];
    [user setObject:thingObject forKey:@"card"];
    [user save];
}

#pragma mark - File

#pragma mark - File Query

+ (UIImage*)imageFromFile:(AVFile*)file{
    if (file == nil) {
        return nil;
    }
    
    NSData *coverData = [file getData];
    if (coverData == nil) {
        return nil;
    }
    
    return [UIImage imageWithData:coverData];
}

#pragma mark - File Save

+ (AVFile*)saveImage:(UIImage*)image{
    if (image == nil) {
        return nil;
    }
    
    NSData *imageData = UIImageJPEGRepresentation(image, 0.75);
    AVFile *file = [AVFile fileWithData:imageData];
    if ([file save] == NO) {
        [HAMLogTool error:@"save image file failed."];
        return nil;
    };
    return file;
}

#pragma mark - Favorites

#pragma mark - Favorites Query

//TODO: may need unsync version!
+ (NSArray*)allFavoriteThingsOfCurrentUser{
    AVUser* user = [AVUser currentUser];
    NSArray* favoritesObjectArray = [user objectForKey:@"favorites"];
    if (favoritesObjectArray == nil || favoritesObjectArray.count == 0) {
        //no favorites
        return [NSArray array];
    }
    
    NSMutableArray* favoritesArray = [NSMutableArray array];
    for (int i = 0; i < favoritesObjectArray.count; i++) {
        AVObject* thingObject = favoritesObjectArray[i];
        [thingObject fetchIfNeeded];
        
        HAMThing* thing = [self thingWithThingAVObject:thingObject];
        [favoritesArray addObject:thing];
    }
    
    return [NSArray arrayWithArray:favoritesArray];
}

+ (Boolean)isThingFavoriteOfCurrentUser:(HAMThing*)targetThing{
    if (targetThing == nil || targetThing.objectID == nil) {
        return false;
    }
    
    AVUser* user = [AVUser currentUser];
    NSArray* favoritesObjectArray = [user objectForKey:@"favorites"];
    if (favoritesObjectArray == nil || favoritesObjectArray.count == 0) {
        //no favorites
        return NO;
    }
    
    for (int i = 0; i < favoritesObjectArray.count; i++) {
        AVObject* thingObject = favoritesObjectArray[i];
        if ([thingObject.objectId isEqualToString:targetThing.objectID]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Favorites Save

+ (void)saveFavoriteThingForCurrentUser:(HAMThing*)thing{
    if (thing == nil) {
        [HAMLogTool warn:@"save nil favorite thing for current user"];
        return;
    }
    
    AVUser* user = [AVUser currentUser];
    AVObject* thingObject = [self thingAVObjectWithThing:thing shouldSaveCover:NO];
    //The favorite array's is ordered by adding consequence. So didn't use addUniqueObject here. Please don't add favorite things that are already favorite, so that there would be no duplicate things in the favorite array.
    [user addObject:thingObject forKey:@"favorites"];
    [user save];
}

+ (void)removeFavoriteThingFromCurrentUser:(HAMThing*)thing{
    if (thing == nil) {
        [HAMLogTool warn:@"remove nil favorite thing for current user"];
        return;
    }
    
    AVUser* user = [AVUser currentUser];
    AVObject* thingObject = [self thingAVObjectWithThing:thing shouldSaveCover:NO];
    [user removeObject:thingObject forKey:@"favorites"];
    [user save];
}

@end