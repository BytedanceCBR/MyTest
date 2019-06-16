//
//  TTFeedDislikeOptionSelectorView.h
//  AWEVideoPlayer
//
//  Created by 曾凯 on 2018/7/11.
//

#import "SSViewBase.h"
#import "TTFeedDislikeWord.h"
#import "TTFeedDislikeOption.h"

NS_ASSUME_NONNULL_BEGIN

@interface TTFeedDislikeOptionSelectorView : SSViewBase
@property (nonatomic, strong) NSDictionary *commonTrackingParameters;
@property (nullable, nonatomic, copy) void (^selectionFinished)(TTFeedDislikeWord *keyword, TTFeedDislikeOptionType optionType);
@property (nonatomic, readonly) UITableView *tableView;
- (void)refreshWithkeywords:(NSArray<TTFeedDislikeWord *> *)keywords;
@end

NS_ASSUME_NONNULL_END

