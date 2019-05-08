//
//  TTAdPromotionManager.h
//  Article
//
//  Created by carl on 2016/12/14.
//
//

#import <Foundation/Foundation.h>
#import <JSONModel/JSONModel.h>

@interface TTActivityModel : JSONModel

@property (nonatomic, copy) NSString *target_url;
@property (nonatomic, copy) NSString *label;
@property (nonatomic, copy) NSString *icon_url;

@end



@interface TTAdPromotionManager : NSObject
+ (BOOL)handleModel:(TTActivityModel *)model condition:(NSDictionary *)baseCondition;
@end

@interface TTAdPromotionManager (TTAdTracker)
+ (void)trackEvent:(NSString *)tag label:(NSString *)label extra:(NSDictionary *)extra;
@end
