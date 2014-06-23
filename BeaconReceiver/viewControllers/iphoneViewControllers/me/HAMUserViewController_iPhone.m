//
//  HAMUserViewController_iPhone.m
//  BeaconReceiver
//
//  Created by daiyue on 5/21/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import "HAMUserViewController_iPhone.h"

#import "HAMCardListViewController_iPhone.h"
#import "HAMCreateThingViewController.h"
#import "HAMBeaconListViewController.h"

#import "SVProgressHUD.h"

#import "HAMThing.h"

#import "HAMAVOSManager.h"

#import "HAMConstants.h"
#import "HAMTools.h"

@interface HAMUserViewController_iPhone () <HAMCardListDelegate>
{
}

@property (nonatomic) HAMThing* selectedThing;

@end

static NSString *kHAMEmbedSegueId = @"embedSegue";

@implementation HAMUserViewController_iPhone {
    HAMCardListViewController_iPhone *listViewController;
    NSMutableArray* thingArray;
}

- (NSArray*)updateThings {
    thingArray = [NSMutableArray array];
    [thingArray addObjectsFromArray:[HAMAVOSManager thingsOfCurrentUserWithSkip:0 limit:kHAMNumberOfThingsInFirstPage]];
    return thingArray;
}

- (NSArray*)loadMoreThings {
    int count = (int)[thingArray count];
    [thingArray addObjectsFromArray:[HAMAVOSManager thingsOfCurrentUserWithSkip:count limit:kHAMNumberOfTHingsInNextPage]];
    return thingArray;
}

- (void)refreshView {
    self.navigationController.navigationBar.barTintColor = nil;
    thingArray = [NSMutableArray array];
    [thingArray addObjectsFromArray:[HAMAVOSManager thingsOfCurrentUserWithSkip:0 limit:kHAMNumberOfThingsInFirstPage]];
    if (listViewController != nil) {
        listViewController.shouldShowPurchaseItem = YES;
        [listViewController updateWithThingArray:thingArray scrollToTop:NO];
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIBarButtonItem *temporaryBarButtonItem = [[UIBarButtonItem alloc] init];
    temporaryBarButtonItem.title = @"";
    self.navigationItem.backBarButtonItem = temporaryBarButtonItem;
    [self refreshView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Unbind/Edit menu

- (void)cellClicked:(HAMThing*)thing{
    self.selectedThing = thing;
    NSString* destructiveButtonTitle = nil;
    if ([HAMAVOSManager isThingBoundToBeacon:thing.objectID]) {
        destructiveButtonTitle = @"解除绑定";
    } else {
        destructiveButtonTitle = @"绑定";
    }

    UIActionSheet* actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:@"我的thing"
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:destructiveButtonTitle
                                  otherButtonTitles:@"详情",@"编辑",nil];
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    switch (buttonIndex) {
        case 0:
            //bind/unbind beacon
            if ([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:@"解除绑定"]) {
                [self unbindThing:self.selectedThing];
            }
            else {
                [self bindThing:self.selectedThing];
            }
            return;
            
        case 1:
            //show detail
            [listViewController showDetailWithThing:self.selectedThing sender:listViewController];
            return;
            
        case 2:
            //edit thing
            [self performSegueWithIdentifier:@"FromMyThingListToEditThing" sender:self.selectedThing];
            return;
            
        default:
            //cancel
            self.selectedThing = nil;
            break;
    }
}

- (void)bindThing:(HAMThing*)thing{
    if (thing.objectID == nil) {
        return;
    }
    
    if (![HAMTools isWebAvailable]) {
        [SVProgressHUD showErrorWithStatus:@"网络不通"];
        return;
    }
    
    if ([HAMAVOSManager ownBeaconCountOfCurrentUser] >= kHAMMaxOwnBeaconCount) {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"最多只能绑定%d个Beacon。",kHAMMaxOwnBeaconCount]];
        return;
    }
    
    [self performSegueWithIdentifier:@"FromMyThingListToBeaconList" sender:thing];
}

- (void)unbindThing:(HAMThing*)thing{
    if (thing.objectID == nil) {
        return;
    }
    
    if (![HAMTools isWebAvailable]) {
        [SVProgressHUD showErrorWithStatus:@"网络不通"];
        return;
    }
    
    [HAMAVOSManager unbindThingWithThingID:thing.objectID withTarget:self callback:@selector(didUnbindThing)];
}

//FIXME: add error param
- (void)didUnbindThing{
    [SVProgressHUD showSuccessWithStatus:@"解除绑定成功"];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:kHAMEmbedSegueId]) {
        if ([segue.destinationViewController isKindOfClass:[HAMCardListViewController_iPhone class]]) {
            listViewController = segue.destinationViewController;
            listViewController.delegate = self;
        }
    } else if ([segue.identifier isEqualToString:@"FromMyThingListToEditThing"]){
        //edit thing
        if ([segue.destinationViewController isKindOfClass:[HAMCreateThingViewController class]]) {
            HAMCreateThingViewController* createThingViewController = segue.destinationViewController;
            createThingViewController.isNewThing = NO;
            createThingViewController.thingToEdit = sender;
        }
    } else if ([segue.identifier isEqualToString:@"FromMyThingListToCreateThing"]){
        //create thing
        if ([segue.destinationViewController isKindOfClass:[HAMCreateThingViewController class]]) {
            HAMCreateThingViewController* createThingViewController = segue.destinationViewController;
            createThingViewController.isNewThing = YES;
        }
    } else if ([segue.identifier isEqualToString:@"FromMyThingListToBeaconList"]){
        if ([segue.destinationViewController isKindOfClass:[HAMBeaconListViewController class]]) {
            HAMBeaconListViewController* beaconListViewController = segue.destinationViewController;
            beaconListViewController.thingToBind = sender;
        }
    }
}

@end
