//
//  FHUGCToolbar.h
//  FHHouseUGC
//
//  Created by wangzhizhou on 2020/1/10.
//

#import "TTUGCToolbar.h"
#import "FHPostUGCMainView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCToolbarReportModel : NSObject
@property (nonatomic, copy) NSString *enterFrom;
@property (nonatomic, copy) NSString *originFrom;
@property (nonatomic, copy) NSString *pageType;
@end

@interface FHUGCToolBarTag : NSObject
@property (nonatomic,   copy)   NSString *groupId;
@property (nonatomic,   copy)   NSString *groupName;
@property (nonatomic,   assign) FHPostUGCTagType tagType;
@property (nonatomic,   assign) NSInteger index;
@end

@protocol FHUGCToolbarDelegate <NSObject>

- (void)selectedTag:(FHUGCToolBarTag *)tagInfo;

- (void)needRelayoutToolbar;

@end

@interface FHUGCToolbar : TTUGCToolbar

@property (nonatomic, weak)  id<FHUGCToolbarDelegate> tagDelegate;
@property (nonatomic, strong) FHUGCToolbarReportModel *reportModel;

@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) FHPostUGCMainView *socialGroupSelectEntry;

- (instancetype)initWithFrame:(CGRect)frame type:(FHPostUGCMainViewType)type;

- (void)layoutTagSelectCollectionViewWithTags:(NSArray<FHUGCToolBarTag *> *)tags;

+ (CGFloat)toolbarHeightWithTags:(NSMutableArray *)tags;

- (void)tagCloseButtonClicked;

- (void)stagePushDuplicateTagIfNeedWithGroupId:(NSString *)groupId;

@end

NS_ASSUME_NONNULL_END
