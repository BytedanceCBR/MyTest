//
//  FHFeedOperationWord.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/16.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, FHFeedOperationWordType) {
    FHFeedOperationWordTypeOther = 0,      //
    FHFeedOperationWordTypeReport = 1,      //举报
    FHFeedOperationWordTypeDelete = 2,      //删除
    FHFeedOperationWordTypeTop = 3,         //置顶
    FHFeedOperationWordTypeCancelTop = 4,   //取消置顶
    FHFeedOperationWordTypeGood = 5,        //加精
    FHFeedOperationWordTypeCancelGood = 6,  //取消加精
    FHFeedOperationWordTypeSelfLook = 7,    //自见
    FHFeedOperationWordTypeEdit = 8,        //编辑
};

@interface FHFeedOperationWord : NSObject

@property(nonatomic,copy)NSString *ID;
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *subTitle;
@property(nonatomic,strong)NSArray *items;
@property(nonatomic,assign)BOOL isSelected;
//是否隐藏，默认是显示
@property(nonatomic,assign)BOOL isHidden;
@property(nonatomic, readonly) FHFeedOperationWordType type;
@property(nonatomic, copy) NSString *serverType;

- (instancetype)initWithDict:(NSDictionary *)dict;

@end
