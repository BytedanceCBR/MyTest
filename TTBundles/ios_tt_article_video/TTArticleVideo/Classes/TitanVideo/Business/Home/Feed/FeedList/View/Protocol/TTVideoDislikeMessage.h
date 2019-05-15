//
//  TTVideoDislikeMessage.h
//  Article
//
//  Created by panxiang on 2017/3/14.
//
//

#import <Foundation/Foundation.h>
#import "TTVFeedListItem.h"

@interface TTVideoDislikeModel : NSObject
@property (nonatomic ,copy)NSString *categoryId;
@property (nonatomic ,copy)NSString *groupId;
@property (nonatomic ,copy)NSString *itemId;
@property (nonatomic ,strong)NSNumber *aggrType;
@property (nonatomic ,strong)TTVFeedListItem *cellEntity;
@end

@protocol TTVideoDislikeMessage <NSObject>

- (void)message_dislikeWithCellEntity:(TTVFeedListItem *)cellEntity hideTip:(BOOL)hideTip;

@end
