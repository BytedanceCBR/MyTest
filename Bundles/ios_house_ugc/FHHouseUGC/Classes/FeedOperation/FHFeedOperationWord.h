//
//  FHFeedOperationWord.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/16.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, FHFeedOperationWordType) {
    FHFeedOperationWordTypeOthers = 0, //
    FHFeedOperationWordTypeReport = 1, //举报
    FHFeedOperationWordTypeDelete = 2, //删除
};

@interface FHFeedOperationWord : NSObject

@property(nonatomic,copy)NSString *ID;
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *subTitle;
@property(nonatomic,strong)NSArray *items;
@property(nonatomic,assign)BOOL isSelected;
@property (nonatomic, readonly) FHFeedOperationWordType type;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end
