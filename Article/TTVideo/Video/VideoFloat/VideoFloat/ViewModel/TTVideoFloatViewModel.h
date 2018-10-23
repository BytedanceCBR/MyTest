
#import "TTTableViewModel.h"
#import "TTDetailModel.h"
#import "ArticleInfoManager.h"

typedef NS_ENUM(NSUInteger, TTVideoFloatNetStatus) {
    TTVideoFloatNetStatus_Failed,
    TTVideoFloatNetStatus_Success,
};

@interface TTVideoFloatViewModel : TTTableViewModel
@property (nonatomic, strong) ArticleInfoManager    *infoManager;
@property (nonatomic, assign) TTVideoFloatNetStatus netStatus;
@property (nonatomic, strong) TTDetailModel         *detailModel;
- (void)loadTableWithData:(Article *)object completeBlock:(void (^)())complete;
@end
