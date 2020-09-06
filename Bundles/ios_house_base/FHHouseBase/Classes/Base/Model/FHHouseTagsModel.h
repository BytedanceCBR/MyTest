//
//  FHHouseTagsModel.h
//  FHHouseBase
//
//  Created by 春晖 on 2019/6/19.
//

#import "JSONModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHHouseTagsModel <NSObject>


@end

@interface FHHouseTagsModel : JSONModel

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *textColor;
@property (nonatomic, copy , nullable) NSString *borderColor;

@end

NS_ASSUME_NONNULL_END
