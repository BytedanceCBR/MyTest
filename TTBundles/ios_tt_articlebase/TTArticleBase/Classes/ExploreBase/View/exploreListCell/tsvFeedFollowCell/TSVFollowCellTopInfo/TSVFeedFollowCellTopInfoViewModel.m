//
//  TSVFeedFollowCellTopInfoViewModel.m
//  Article
//
//  Created by dingjinlu on 2017/12/7.
//

#import "TSVFeedFollowCellTopInfoViewModel.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TSVShortVideoOriginalData.h"
#import "TSVUserModel.h"

#define kTopInfoViewHeight      60.f

@interface TSVFeedFollowCellTopInfoViewModel()

@property (nonatomic, strong) ExploreOrderedData *orderedData;

@end

@implementation TSVFeedFollowCellTopInfoViewModel

+ (BOOL)shouldShowTopInfoViewWithData:(ExploreOrderedData *)orderedData
{
    // add by zjing 小视频都展示
    return YES;
    
//    if (orderedData.cellCtrls && [orderedData.cellCtrls isKindOfClass:[NSDictionary class]]) {
//        NSInteger layoutStyle = [orderedData.cellCtrls tt_integerValueForKey:@"cell_layout_style"];
//        if (layoutStyle == 100) {
//            return YES;
//        } else if (layoutStyle == 101) {
//            return NO;
//        }
//    }
//    return NO;
}

+ (CGFloat)heightWithData:(ExploreOrderedData *)orderedData
{
    return kTopInfoViewHeight;
}

- (instancetype)initWithOrderedData:(ExploreOrderedData *)orderedData
{
    if (self = [super init]) {
        self.orderedData = orderedData;
        self.model = self.orderedData.shortVideoOriginalData.shortVideo;
    }
    return self;
}

- (ExploreOrderedData *)data
{
    return self.orderedData;
}

- (NSString *)title
{
    return self.model.author.name;
}

- (NSString *)info
{
    return self.model.author.desc;
}

- (NSString *)imageURL
{
    return self.model.author.avatarURL;
}

- (BOOL)isFollowing
{
    return self.model.author.isFollowing;
}

- (TTShortVideoModel *)shortVideoModel
{
    return self.model;
}

@end
