
#import "TTTableViewModel.h"

@implementation TTTableViewModel


- (instancetype)init
{
    self = [super init];
    if (self) {
        self.dataArr = [NSMutableArray array];
    }
    return self;
}

- (void)loadDataWithParameters:(TTApiParameter *)parameter completeBlock:(void (^)())complete
{
    if (!isNull(complete)) {
        complete();
    }
}

- (void)loadMoreWithParameters:(TTApiParameter *)parameter completeBlock:(void (^)())complete
{
    if (!isNull(complete)) {
        complete();
    }
}

- (void)loadTableWithData:(id)object completeBlock:(void (^)())complete
{
    
}

@end
