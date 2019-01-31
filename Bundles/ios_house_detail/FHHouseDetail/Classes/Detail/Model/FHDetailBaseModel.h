//
//  FHDetailBaseModel.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/1/30.
//

#import <Foundation/Foundation.h>


NS_ASSUME_NONNULL_BEGIN

@protocol FHDetailBaseModelProtocol <NSObject>

@end

@protocol FHBaseExpandModelProtocol <FHDetailBaseModelProtocol>

@required
@property (nonatomic, assign)   BOOL       isExpand; // 是否折叠展开

@end

@interface FHDetailTest1Model : NSObject <FHDetailBaseModelProtocol>

@end

@interface FHDetailTest2Model : NSObject <FHBaseExpandModelProtocol>

@property (nonatomic, assign)   BOOL       isExpand;

@end

@interface FHDetailTest3Model : NSObject <FHDetailBaseModelProtocol>

@end

NS_ASSUME_NONNULL_END
