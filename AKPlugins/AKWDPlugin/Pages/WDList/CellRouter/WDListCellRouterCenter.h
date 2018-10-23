//
//  WDListCellRouterCenter.h
//  TTWenda
//
//  Created by wangqi.kaisa on 2018/1/3.
//

#import <Foundation/Foundation.h>
#import "WDApiModel.h"

@class WDListCellDataModel;

/*
 * 1.4 列表页的cell对应的用于计算布局类的协议（方便折叠列表页共用）
 */

@protocol WDListCellLayoutModelBaseProtocol <NSObject>

@property (nonatomic, strong, readonly) WDListCellDataModel *dataModel;

@property (nonatomic, assign) CGFloat cellCacheHeight;

- (instancetype)initWithDataModel:(WDListCellDataModel *)dataModel;

- (void)calculateLayoutIfNeedWithCellWidth:(CGFloat)cellWidth;

@end

/*
 * 1.3 列表页的cell协议
 */

@protocol WDListCellBaseProtocol <NSObject>

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
                    gdExtJson:(NSDictionary *)gdExtJson
                    apiParams:(NSDictionary *)apiParams;

- (void)refreshWithCellLayoutModel:(id <WDListCellLayoutModelBaseProtocol>)cellLayoutModel cellWidth:(CGFloat)cellWidth;

- (void)cellDidSelected;

@end

/*
 * 1.4 列表页的video类型cell协议
 * 1.31 此协议其实可直接继承于上面的协议，但是因为旧样式cell并没有对不同类型cell做拆分，所以暂不继承
 */

@protocol WDListCellVideoProtocol <NSObject>

@property (nonatomic, assign) CGRect videoCoverPicFrame;

- (void)videoPlayButtonClicked;

- (void)stopPlayingMovie;

@end

/*
 * 1.3 列表页的cell分发中心
 */

@interface WDListCellRouterCenter : NSObject

+ (instancetype)sharedInstance;

- (BOOL)canRecgonizeData:(WDListCellDataModel *)data;

- (CGFloat)heightForCellLayoutModel:(id <WDListCellLayoutModelBaseProtocol>)cellLayoutModel cellWidth:(CGFloat)cellWidth;

- (UITableViewCell <WDListCellBaseProtocol>*)dequeueTableCellForLayoutModel:(id <WDListCellLayoutModelBaseProtocol>)cellLayoutModel
                                                                  tableView:(UITableView *)tableView
                                                                  indexPath:(NSIndexPath *)indexPath
                                                                  gdExtJson:(NSDictionary *)gdExtJson
                                                                  apiParams:(NSDictionary *)apiParams
                                                                   pageType:(WDWendaListRequestType)pageType;

@end
