//
//  FHHouseDislikeWord.h
//  FHHouseHome
//
//  Created by 谢思铭 on 2019/7/23.
//

//#import <Foundation/Foundation.h>
//
//NS_ASSUME_NONNULL_BEGIN
//
//@interface FHHouseDislikeWord : NSObject
//
//@end
//
//NS_ASSUME_NONNULL_END

#import <Foundation/Foundation.h>

@interface FHHouseDislikeWord : NSObject

@property(nonatomic,copy)NSString *ID;
@property(nonatomic,copy)NSString *name;
@property(nonatomic,assign)BOOL isSelected;
@property(nonatomic,strong)NSArray *exclusiveIds;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end
