//
//  TSVFeedFollowCellTopInfoViewModel.h
//  Article
//
//  Created by dingjinlu on 2017/12/7.
//

#import <Foundation/Foundation.h>
@class ExploreOrderedData;
@class TTShortVideoModel;

@interface TSVFeedFollowCellTopInfoViewModel : NSObject

@property (nonatomic, strong) TTShortVideoModel *model;

+ (BOOL)shouldShowTopInfoViewWithData:(ExploreOrderedData *)orderedData;

+ (CGFloat)heightWithData:(ExploreOrderedData *)orderedData;

- (instancetype)initWithOrderedData:(ExploreOrderedData *)orderedData;

- (ExploreOrderedData *)data;

- (NSString *)title;

- (NSString *)info;

- (NSString *)imageURL;

- (BOOL)isFollowing;

- (TTShortVideoModel *)shortVideoModel;

@end
