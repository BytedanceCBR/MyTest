//
//  FHCardSliderCellModel.h
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/3/10.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHCardSliderCellModel : NSObject

@property (nonatomic, copy , nullable) NSString *imageUrl;
@property (nonatomic, copy , nullable) NSString *desc;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *type;
@property (nonatomic, copy , nullable) NSString *groupId;
@property (nonatomic, copy , nullable) NSString *schema;
//埋点信息
@property (nonatomic, strong , nullable) NSDictionary *tracer;

@end

NS_ASSUME_NONNULL_END
