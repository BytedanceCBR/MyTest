//
//  FHPostUGCSelectedGroupHistoryView.h
//  FHHouseUGC
//
//  Created by wangzhizhou on 2019/8/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

#define kSelectedGroupHistoryWhenPostSuccessfully @"kSelectedGroupHistoryWhenPostSuccessfully"

@interface FHPostUGCSelectedGroupModel: NSObject<NSCoding>
@property (nonatomic, copy) NSString *socialGroupId;
@property (nonatomic, copy) NSString *socialGroupName;
@end

@protocol FHPostUGCSelectedGroupHistoryViewDelegate <NSObject>
- (void)selectedHistoryGroup:(FHPostUGCSelectedGroupModel *)item;
@end

@interface FHPostUGCSelectedGroupHistoryView : UIView

@property (nonatomic, readonly) FHPostUGCSelectedGroupModel *model;

-(instancetype)initWithFrame:(CGRect)frame
                    delegate:(id<FHPostUGCSelectedGroupHistoryViewDelegate>) delegate
                historyModel:(FHPostUGCSelectedGroupModel *)model;
@end

NS_ASSUME_NONNULL_END
