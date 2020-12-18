//
//  FHHousedetailModelManager.h
//  FHHouseBase
//
//  Created by bytedance on 2020/12/2.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHHousedetailModelManager : NSObject

+(instancetype)sharedInstance;
- (id)getHouseDetailModelWith:(NSString *)key;
- (void)saveHouseDetailModel:(id)model With:(NSString *)key;
- (CGFloat)getSizeOfCache;
- (void )cleanCache;
@end


NS_ASSUME_NONNULL_END
