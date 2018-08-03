
#import <Foundation/Foundation.h>
#import "TTTableViewModel.h"

@interface TTTableConfigure : NSObject
@property (nonatomic, assign ,nullable) Class tableHeaderClass;
@property (nonatomic, assign ,nullable) Class tableFooterClass;
@property (nonatomic, assign ,nonnull) Class dataSourceClass;
@property (nonatomic ,assign ,nonnull) Class  viewModelClass;
@end
