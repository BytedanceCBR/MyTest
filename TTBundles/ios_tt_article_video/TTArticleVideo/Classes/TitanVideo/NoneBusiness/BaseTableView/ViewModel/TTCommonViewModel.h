
#import <Foundation/Foundation.h>
#import "TTApiParameter.h"

@interface TTCommonViewModel : NSObject
@property (nonatomic        ) NSObject       *netData;
@property (nonatomic        ) NSError        *error;

- (void)loadDataWithParameters:(TTApiParameter *)parameter completeBlock:(void (^)(id data ,NSError *error))complete;
- (void)loadMoreWithParameters:(TTApiParameter *)parameter completeBlock:(void (^)(id data ,NSError *error))complete;
@end
