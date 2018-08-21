//
//  TTHTSWaterfallCollectionViewCell.h
//  Article
//
//  Created by 王双华 on 2017/4/13.
//
//

#import <UIKit/UIKit.h>
#import "TSVWaterfallCollectionViewCellProtocol.h"

typedef NS_ENUM(NSUInteger, TTHTSWaterfallCollectionCellUIType)
{
    TTHTSWaterfallCollectionCellUITypeNone,
    TTHTSWaterfallCollectionCellUITypeRelationship,    //小头像 + 红色标签
};

@interface TTHTSWaterfallCollectionViewCell : UICollectionViewCell <TSVWaterfallCollectionViewCellProtocol>

@property (nonatomic, copy) NSString *listEntrance;

@end
