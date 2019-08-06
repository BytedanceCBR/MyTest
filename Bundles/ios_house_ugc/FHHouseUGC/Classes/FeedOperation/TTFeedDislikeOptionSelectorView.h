//
//  TTFeedDislikeOptionSelectorView.h
//  AWEVideoPlayer
//
//  Created by 曾凯 on 2018/7/11.
//

#import "SSViewBase.h"
#import "FHFeedOperationWord.h"
#import "FHFeedOperationOption.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTFeedDislikeOptionSelectorView : SSViewBase
@property (nonatomic, strong) NSDictionary *commonTrackingParameters;
@property (nullable, nonatomic, copy) void (^selectionFinished)(FHFeedOperationWord *keyword, FHFeedOperationOptionType optionType);
@property (nonatomic, readonly) UITableView *tableView;
@property (nonatomic, copy) void(^dislikeTracerBlock)(void);

- (void)refreshWithkeywords:(NSArray<FHFeedOperationWord *> *)keywords;
@end

NS_ASSUME_NONNULL_END

