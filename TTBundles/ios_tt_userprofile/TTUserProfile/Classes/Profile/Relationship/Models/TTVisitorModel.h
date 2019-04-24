//
//  TTVisitorModel.h
//  Article
//
//  Created by liuzuopeng on 8/10/16.
//
//

#import <Foundation/Foundation.h>
#import "TTVisitorResponseModel.h"


@class TTVisitorFormattedModelItem;
@class TTVisitorFormattedModel;



/**
 * Packaging TTVisitorModel to native formatted model
 */
@interface TTVisitorFormattedModelItem : TTVisitorItemModel
@property (nonatomic, assign) BOOL isFirstVisitorOfDay; // 是否是某天的第一个访问用户
@property (nonatomic, assign) NSInteger list_count;    // 当前的数目
@property (nonatomic, assign) NSInteger visit_device_count; //匿名访客数
@property (nonatomic, assign) NSInteger visit_count_total;  //历史访客总数
@property (nonatomic, assign) NSInteger visit_count_recent; //本次的访客数量

+ (instancetype)modelWithVisitorItem:(TTVisitorItemModel *)obj;
- (NSString *)formattedTimeLabel;
- (NSString *)formattedDateLabel;
- (BOOL)isVerifiedUser;
- (BOOL)isToutiaohaohaoUser;
@end

@interface TTVisitorFormattedModel : NSObject
@property (nonatomic, assign) BOOL       has_more;
@property (nonatomic, strong) NSNumber  *cursor;
@property (nonatomic, assign) NSInteger list_count;    // 当前的数目
@property (nonatomic, assign) NSInteger visit_device_count; //匿名访客数
@property (nonatomic, assign) NSInteger visit_count_total;  //历史访客总数
@property (nonatomic, assign) NSInteger visit_count_recent; //本次的访客数量

@property (nonatomic, strong) NSMutableArray<TTVisitorFormattedModelItem *> *users;

+ (instancetype)formattedModelFromVisitorModel:(TTVisitorModel *)aModel;

/**
 *  是否存在历史访客数，当且仅当visit_count_total和visit_count_recent有一个不为0
 *
 *  @return 标记
 */
- (BOOL)hasHistoryVisitor;
/**
 *  是否存在未登录的访客数
 *
 *  @return 标记
 */
- (BOOL)hasNotLoginVisitor;
@end
