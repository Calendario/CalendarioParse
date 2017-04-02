//
//  PrivateMessagesHelper.h
//  Calendario
//
//  Created by Daniel Sadjadian on 31/03/2017.
//  Copyright © 2017 Calendario. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>

typedef void(^countCompletion)(NSNumber *unreadCount);
typedef void(^threadDataCompletion)(NSMutableArray *allData);

@interface PrivateMessagesHelper : NSObject {
    
}

// Data methods.
-(void)getTotalNumberOfUnreadMessages:(countCompletion)dataBlock;
-(void)getUserThreadsWithInfo:(threadDataCompletion)dataBlock;
-(NSMutableArray *)setThreadDataWithoutExtraData:(NSArray *)data;

@end
