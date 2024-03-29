//
//  HAMAppDelegate.m
//  BeaconReceiver
//
//  Created by Dai Yue on 14-2-18.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>
#import <AVOSCloudSNS/AVOSCloudSNS.h>
#import "HAMAppDelegate.h"

#import "HAMBeaconManager.h"
#import "HAMTourManager.h"
#import "HAMAVOSManager.h"
#import "HAMUserDefaultManager.h"

#import "HAMLogTool.h"

@implementation HAMAppDelegate

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

static NSString *kHAMAVOSAppId = @"s55x7mngao4iv95w2ebsjpo80o2moqwlmolk66fjhpr7xys6";
static NSString *kHAMAVOSAppKey = @"ljqpcds0mt9cn3noaqs3armqgcyhew4setb788pdqc5fbow1";

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //AVOS
    [AVOSCloud setApplicationId:kHAMAVOSAppId clientKey:kHAMAVOSAppKey];
    if ([HAMUserDefaultManager isDebugMode]) {
        [AVAnalytics setAnalyticsEnabled:NO];
    }
    
    
    //UITabBar
    [[UITabBar appearance] setSelectedImageTintColor:[UIColor colorWithRed:229.0f / 255.0f green:126.0f / 225.0f blue:62.0f / 225.0f alpha:1]];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[HAMBeaconManager beaconManager] setBackGroundStatus:YES];
    [self saveContext];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[HAMBeaconManager beaconManager] setBackGroundStatus:YES];
    [self saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[HAMBeaconManager beaconManager] setBackGroundStatus:NO];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [[HAMBeaconManager beaconManager] setBackGroundStatus:NO];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[HAMBeaconManager beaconManager] stopMonitor];
    [[HAMTourManager tourManager] saveTour];
    [self saveContext];
}

/*
- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskLandscape;
}
 */

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //[[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    return YES;
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    return [AVOSCloudSNS handleOpenURL:url];
}

/*
- (void)application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    //[HAMLogTool trace:@"Fetch started."];
    
    //[HAMCouponManager syncWithServer];
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    NSDate *now = [NSDate date];
    localNotification.fireDate = now;
    localNotification.alertBody = @"Fetch started once again.";
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    //completionHandler(UIBackgroundFetchResultNewData);
}
*/


- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    NSLog(@"%@",notification);
    /*if ([self.window.rootViewController isKindOfClass:[UITabBarController class]])
    {
        //UITabBarController *rootView = self.window.rootViewController;
        //[rootView setSelectedIndex:0];
        UINavigationController *recommandedNavController = [[rootView viewControllers]objectAtIndex:0];
        HAMCouponTableViewController *recommandedView = [recommandedNavController.viewControllers objectAtIndex:0];
        //HAMCoupon *coupon = [[notification userInfo] objectForKey:@"coupon"];
        //if(coupon) recommandedView.notifiedCoupon = coupon;
        [recommandedView performSegueWithIdentifier:@"showCouponDetail" sender:recommandedView];
    }*/
}


- (void)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

#pragma mark - Core Data stack

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"HAMCoreData" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"HAMCoreData.sqlite"];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
         
         Typical reasons for an error here include:
         * The persistent store is not accessible;
         * The schema for the persistent store is incompatible with current managed object model.
         Check the error message to determine what the actual problem was.
         
         
         If the persistent store is not accessible, there is typically something wrong with the file path. Often, a file URL is pointing into the application's resources directory instead of a writeable directory.
         
         If you encounter schema incompatibility errors during development, you can reduce their frequency by:
         * Simply deleting the existing store:
         [[NSFileManager defaultManager] removeItemAtURL:storeURL error:nil]
         
         * Performing automatic lightweight migration by passing the following dictionary as the options parameter:
         @{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES}
         
         Lightweight migration will only work for a limited set of schema changes; consult "Core Data Model Versioning and Data Migration Programming Guide" for details.
         
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}


@end
