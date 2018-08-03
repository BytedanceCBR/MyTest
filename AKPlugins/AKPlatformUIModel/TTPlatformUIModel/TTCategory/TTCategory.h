//
//  TTCategory.h
//  Article
//
//  Created by Chen Hong on 16/8/11.
//
//

#import "TTEntityBase.h"
#import "TTCategoryDefine.h"

// 频道model协议
@protocol TTFeedCategory <NSObject>

// 频道的ID
@property (nonatomic, retain, nonnull) NSString *categoryID;

// 关心ID
@property (nonatomic, retain, nullable) NSString *concernID;

// 频道类型
@property (nonatomic) TTFeedListDataType listDataType;

@end

@interface TTCategory : TTEntityBase <TTFeedCategory>
/**
 *  频道的ID
 */
@property (nonatomic, retain, nonnull) NSString * categoryID;
/**
 *  关心的ID
 */
@property (nonatomic, retain, nullable) NSString * concernID;
/**
 *  频道显示的name
 */
@property (nonatomic, retain, nullable) NSString * name;
/**
 *  4.3 新增，预留字段
 */
@property (nonatomic, retain, nullable) NSString * iconURL;
/**
 *  仅对wap类型有效
 */
@property (nonatomic, retain, nullable) NSString * webURLStr;
/**
 *  是否提示新频道, 1： 提示， 0: 不提示
 */
@property(nonatomic, assign)NSUInteger tipNew;

/**
 *  频道类型
 */
@property (nonatomic, assign) TTFeedListDataType listDataType;
/**
 *  是否是订阅状态
 */
@property (nonatomic, assign) NSUInteger subscribed;
/**
 *  排序
 */
@property (nonatomic, assign) NSUInteger orderIndex;
/**
 *  服务端已删除该频道，客户端打标记，不从数据库真实删除
 */
@property (nonatomic, assign) NSUInteger ttDeleted;
/**
 *  标志位，具体含义见categoryDefine中的定义
 */
@property(nonatomic, assign)NSUInteger flags;
/**
 *  该字段不持久化存储， 尽在解析json的时候赋值，使用。
 */
//@property(nonatomic, retain)NSNumber * defaultAdd;
/**
 *  一级频道类型, TTCategoryModelTopType, 具体含义见categoryDefine中的定义
 */
@property (nonatomic, assign) NSUInteger topCategoryType;

/**
 *  是否是推荐频道左侧的固定频道
 */
@property (nonatomic, assign)BOOL isPreFixedCategory;

/**
 *  说明：为特殊需求添加字段
 *  目的：修改频道显示名字，替换name字段，不参与数据库存储
 */
@property (nonatomic, strong, nullable) NSString *displayName;

/**
 *  频道item尺寸缓存，持久化
 */
@property (nonatomic, strong, nullable) NSValue *cachedSize;


/**
 该字段不持久化存储， 主要是为了统计使用。
 *  catalog切换的类型（click，flip, categoryManager等）
 */
//@property (nonatomic, strong, nullable)NSString * enterType;

/**
 *  频道上点击title 刷新会导致view重新调用viewWillAppear。
 *  实际上只有点击了不同的频道才有viewwillappear的必要。
 * 此字段用来判断 如果点击的还是当前显示的频道，就把didClickedSameCategory置为YES
 *  @return didClickedSameCategory
 */

//@property (nonatomic, assign)BOOL didClickedSameCategory;

- (NSDictionary * _Nullable)dictionary;

@end
