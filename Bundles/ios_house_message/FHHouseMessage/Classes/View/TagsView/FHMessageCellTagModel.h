//
//  FHMessageCellTagModel.h
//  FHHouseMessage
//
//  Created by wangzhizhou on 2020/12/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, FHMessageCellTagPriority) {
    FHMessageCellTagPriorityHigh = 0,
    FHMessageCellTagPriorityNormal = 1000,
    FHMessageCellTagPriorityLow = 2000,
};

@interface FHMessageCellTagModel : NSObject
@property (nonatomic, copy)     NSString    *name;
@property (nonatomic, strong)   UIFont      *font;
@property (nonatomic, strong)   UIColor     *textColor;
@property (nonatomic, strong)   UIColor     *backgroundColor;
@property (nonatomic, assign)   FHMessageCellTagPriority priority;
- (instancetype)initWithName:(NSString *)name;
- (instancetype)initWithName:(NSString *)name priority:(FHMessageCellTagPriority)priority;
@end

NS_ASSUME_NONNULL_END
