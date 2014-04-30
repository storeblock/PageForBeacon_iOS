//
//  HAMDetailViewController_iPhone.h
//  BeaconReceiver
//
//  Created by daiyue on 4/27/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HAMBeaconManager.h"

@interface HAMArtDetailViewController_iPhone : UIViewController <HAMBeaconManagerDelegate, UIWebViewDelegate> {
    NSString *pageURL;
    NSString *pageTitle;
    UIGestureRecognizer *switchDetailViewRecognizer;
}

@property (weak, nonatomic) IBOutlet UIWebView *detailWebView;
@property HAMHomepageData *homepage;

@end