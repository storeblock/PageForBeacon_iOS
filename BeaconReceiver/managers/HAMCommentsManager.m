//
//  HAMCommentsManager.m
//  BeaconReceiver
//
//  Created by daiyue on 4/24/14.
//  Copyright (c) 2014 Beacon Test Group. All rights reserved.
//

#import <AVOSCloud/AVOSCloud.h>
#import "HAMCommentsManager.h"
#import "HAMCommentData.h"
#import "HAMTools.h"

@implementation HAMCommentsManager

static HAMCommentsManager *commentsManager;

+ (HAMCommentsManager*)commentsManager {
    @synchronized(self) {
        if (commentsManager == nil) {
            commentsManager = [[HAMCommentsManager alloc] init];
        }
    }
    return commentsManager;
}

-(id)init{
    if (self = [super init]) {
        self.timer = nil;
    }
    return self;
}

- (NSArray*)commentsWithPageDataID:(NSString *)pageDataID {
    if (self.comments == nil || [self.comments count] == 0) {
        return nil;
    } else {
        NSMutableArray *array = [NSMutableArray array];
        for (HAMCommentData* comment in self.comments) {
            if ([comment.pageDataID isEqualToString:pageDataID]) {
                [array addObject:comment];
            }
        }
        return array;
    }
}

- (void)updateComments {
    @synchronized (self) {
        if ([HAMTools isWebAvailable]) {
            AVQuery *query = [AVQuery queryWithClassName:@"Comment"];
            [query orderByAscending:@"createdAt"];
            self.comments = nil;
            [query findObjectsInBackgroundWithBlock:^(NSArray *objectArray, NSError *error) {
                @synchronized (self) {
                    if (error == nil && objectArray != nil && [objectArray count] > 0) {
                        self.comments = [NSMutableArray array];
                        for (AVObject* commentObject in objectArray) {
                            HAMCommentData *comment = [[HAMCommentData alloc] init];
                            comment.userID = [commentObject objectForKey:@"userID"];
                            comment.pageDataID = [commentObject objectForKey:@"thingID"];
                            comment.content = [commentObject objectForKey:@"content"];
                            comment.userName = [commentObject objectForKey:@"userName"];
                            [self.comments addObject:comment];
                        }
                    }
                    if (self.delegate) {
                        [self.delegate refresh];
                    }
                }
            }];
        }
        if (self.timer == nil) {
            self.timer = [NSTimer scheduledTimerWithTimeInterval:30.0f target:self selector:@selector(handleTimer) userInfo:nil repeats:YES];
            [self.timer setFireDate:[NSDate date]];
        }
    }
}

- (void)handleTimer {
    [[HAMCommentsManager commentsManager] updateComments];
    NSLog(@"%@",self.timer);
}

- (void)addComment:(HAMCommentData *)comment {
    AVObject *commentObject = [AVObject objectWithClassName:@"Comment"];
    [commentObject setObject:comment.userID forKey:@"userID"];
    [commentObject setObject:comment.pageDataID forKey:@"thingID"];
    [commentObject setObject:comment.content forKey:@"content"];
    [commentObject setObject:comment.userName forKey:@"userName"];
    [commentObject save];
    [self.timer setFireDate:[NSDate date]];
}

@end
