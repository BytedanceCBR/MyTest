//
//  SSInHouseFeature.h
//  Article
//
//  Created by liufeng on 2017/8/14.
//
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface SSInHouseFeature : NSObject <NSCopying>

//默认值是NO
@property (nonatomic, readonly, class) SSInHouseFeature *defaultFeatureWithDisable;
//默认值是YES
@property (nonatomic, readonly, class) SSInHouseFeature *defaultLocalFeatureWithEnable;
// 默认为 NO
@property (nonatomic, assign) BOOL login_phone_only;
// 默认为 NO
@property (nonatomic, assign) BOOL show_quick_feedback_gate;

// 转换为字典
@property (nonatomic, copy, readonly) NSDictionary *dictionaryRepresentation;

- (SSInHouseFeature *)join:(SSInHouseFeature *)one;
- (instancetype)initWithDictionary:(NSDictionary *)dict;

@end
NS_ASSUME_NONNULL_END

