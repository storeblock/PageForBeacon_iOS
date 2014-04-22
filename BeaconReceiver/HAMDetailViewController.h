//
//  HAMDetailViewController.h
//  BeaconReceiver
//
//  Created by Dai Yue on 14-4-11.
//  Copyright (c) 2014年 Beacon Test Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HAMBeaconManager.h"

@class HAMHomepageData;

@interface HAMDetailViewController : UIViewController <UIWebViewDelegate, HAMBeaconManagerDelegate> {
    NSString *pageURL;
    NSString *pageTitle;
    UIGestureRecognizer *backToHomeRecognizer;
}

@property (weak, nonatomic) IBOutlet UIWebView *detailWebView;

@property HAMHomepageData *homepage;

@end
