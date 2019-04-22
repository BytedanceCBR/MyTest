//
//  SSItemActionSender.h
//  Article
//
//  Created by Zhang Leonardo on 14-7-20.
//
//

#import <Foundation/Foundation.h>

typedef void(^SSItemActionFinishBlock)(NSDictionary *result, NSError *error);

typedef NS_ENUM(NSUInteger, SSItemActionType)
{
    SSItemActionTypeADDislike = 1,
    SSItemActionTypeADUnDislike = 2
};

@interface SSItemActionSender : NSObject


+ (id)shareManager;

- (void)sendADItemAction:(SSItemActionType)type adID:(NSNumber *)aID finishBlock:(SSItemActionFinishBlock)finishBlock;


@end
