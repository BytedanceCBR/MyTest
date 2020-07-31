//

//  FHMessageViewController.h
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/1/31.
//

#import "FHBaseViewController.h"
#import "FHNoNetHeaderView.h"
#import "FHMessageSegmentedViewController.h"
#import "FHMessageViewModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, FHMessageRequestDataType) {
    FHMessageRequestDataTypeIM = 0,
    FHMessageRequestDataTypeSystem
};

@interface FHMessageViewController<UIViewControllerErrorHandler> : FHBaseViewController 

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic , strong) UIView *containerView;
@property(nonatomic, strong) FHNoNetHeaderView *notNetHeader;
@property(nonatomic, strong) FHMessageViewModel *viewModel;

@property (nonatomic, weak) FHMessageSegmentedViewController *fatherVC;

@property (nonatomic) BOOL isSegmentedChildViewController;

@property (nonatomic) FHMessageRequestDataType dataType;

@property (nonatomic, copy) void (^updateRedPoint)(NSInteger chatNumber, BOOL hasRedPoint, NSInteger systemMessageNumber);

- (void)addEnterCategoryLogWithType:(NSString *)enterType;

- (NSString *)getPageType;
- (CGFloat) getBottomMargin;
- (BOOL) leftActionHidden;
- (BOOL) isAlignToSafeBottom;
- (void) startLoadData;

@end

NS_ASSUME_NONNULL_END
