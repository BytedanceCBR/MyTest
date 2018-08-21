
#import "TTApiParameter.h"

@interface TTTableViewModel : NSObject

@property (nonatomic,strong ) id             netData;
@property (nonatomic        ) NSError        *error;

@property (nonatomic        ) NSMutableArray *dataArr;
@property (nonatomic        ) id             headerData;
@property (nonatomic        ) id             footerData;
@property (nonatomic,assign ) BOOL           hasMore;

- (void)loadDataWithParameters:(TTApiParameter *)parameter completeBlock:(void (^)())complete;
- (void)loadMoreWithParameters:(TTApiParameter *)parameter completeBlock:(void (^)())complete;
- (void)loadTableWithData:(id)object completeBlock:(void (^)())complete;
@end


