//
//  FHDetailHouseTitleModel.h
//  FHHouseDetail
//
//  Created by liuyu on 2019/11/26.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailHouseTitleModel : NSObject
@property (nonatomic, copy)     NSString       *titleStr;
@property (nonatomic, strong)   NSArray       *tags;// FHHouseTagsModel item类型
@end

NS_ASSUME_NONNULL_END
