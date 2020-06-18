//
//  FHFindHouseHelperCell.h
//  AKCommentPlugin
//
//  Created by wangxinyu on 2020/6/16.
//

#import <UIKit/UIKit.h>
#import "FHListBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHFindHouseHelperCell : FHListBaseCell

@property (nonatomic, copy) void(^cellTapAction)(NSString *);

- (void)updateWithData:(id)data;

@end

NS_ASSUME_NONNULL_END
