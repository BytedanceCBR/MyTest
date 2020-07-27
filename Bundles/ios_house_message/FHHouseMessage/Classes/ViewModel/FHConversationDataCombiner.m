//
//  FHBConversationDataCombiner.m
//  AFgzipRequestSerializer
//
//  Created by leo on 2019/2/13.
//

#import "FHConversationDataCombiner.h"
#import "IMConversation.h"
#import "FHUnreadMsgModel.h"

#import "IMConversation+Comparable.h"

#import "FHUnreadMsgDataUnreadModel+Comparable.h"
#import "RXCollection.h"
#import "FHEnvContext.h"
#import "FHMessageManager.h"

@interface FHConversationDataCombiner ()
@property (nonatomic, strong) NSArray<IMConversation*>* conversations;
@property (nonatomic, strong) NSArray<FHUnreadMsgDataUnreadModel*>* channels;
@property (nonatomic, strong) NSArray* items;
@end

@implementation FHConversationDataCombiner

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.conversations = @[];
        self.channels = @[];
        self.items = @[];
    }
    return self;
}

-(void)resetConversations:(NSArray<IMConversation*>*)conversations {
    self.conversations = conversations;
    [self resetAllItems];
}

-(void)resetSystemChannels:(NSArray<FHUnreadMsgDataUnreadModel*>*)channels ugcUnreadMsg:(FHUnreadMsgDataUnreadModel*)ugcUnreadMsg{
    NSNumber* count = [channels rx_foldInitialValue:@(0) block:^id(id memo, FHUnreadMsgDataUnreadModel* each) {
        NSInteger count = [memo unsignedIntegerValue];
        return @(count += [each.unread integerValue]);
    }];
    [[FHEnvContext sharedInstance].messageManager setUnreadSystemMsgCount:[count integerValue]];

    NSMutableArray *combineChannels = [NSMutableArray array];
    [combineChannels addObjectsFromArray:channels];
    if(ugcUnreadMsg && ugcUnreadMsg.hasHistoryMsg){
        [combineChannels addObject:ugcUnreadMsg];
    }
    self.channels = [combineChannels copy];
    [self resetAllItems];
}

-(NSArray*)allItems {
    return _items;
}

- (NSArray *)conversationItems {
    return _conversations;
}

- (NSArray *)channelItems {
    return _channels;
}

-(void)resetAllItems {
    NSMutableArray<id<ConversationComparable>>* theItems = [NSMutableArray arrayWithArray:_conversations];
    [theItems addObjectsFromArray:_channels];
    NSArray* result = [theItems sortedArrayUsingComparator:^NSComparisonResult(id<ConversationComparable>  _Nonnull obj1, id<ConversationComparable>  _Nonnull obj2) {
        return [FHConversationDataCombiner conversationComparison:obj1 toOther:obj2];
    }];
    self.items = result;
}

-(NSInteger)numberOfItems {
    return [_conversations count] + [_channels count];
}

+(NSComparisonResult)conversationComparison:(id<ConversationComparable>)one toOther:(id<ConversationComparable>)other {
    if ([one isStickOnTop] && [other isStickOnTop]) {
        if ([one updateTime] > [other updateTime]) {
            return NSOrderedAscending;
        } else if ([one updateTime] == [other updateTime]) {
            return NSOrderedSame;
        } else {
            return NSOrderedDescending;
        }
    } else if ([one isStickOnTop]) {
        return NSOrderedAscending;
    } else if ([other isStickOnTop]) {
        return NSOrderedDescending;
    } else {
        if ([one updateTime] > [other updateTime]) {
            return NSOrderedAscending;
        } else if ([one updateTime] == [other updateTime]) {
            return NSOrderedSame;
        } else {
            return NSOrderedDescending;
        }
    }
}


@end
