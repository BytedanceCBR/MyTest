//
//  FHBConversationDataCombiner.h
//  AFgzipRequestSerializer
//
//  Created by leo on 2019/2/13.
//

#import <Foundation/Foundation.h>
@class IMConversation;
@class FHUnreadMsgDataUnreadModel;


NS_ASSUME_NONNULL_BEGIN

@protocol ConversationComparable <NSObject>

-(NSTimeInterval)updateTime;

-(BOOL)isStickOnTop;

@end

@interface FHConversationDataCombiner : NSObject

-(void)resetConversations:(NSArray<IMConversation*>*)conversations;

-(void)resetSystemChannels:(NSArray<FHUnreadMsgDataUnreadModel*>*)channels;

-(NSUInteger)numberOfItems;

-(NSArray*)allItems;
@end

NS_ASSUME_NONNULL_END
