//
//  WDFetchAnswerContentHelper.h
//  Article
//
//  Created by wangqi.kaisa on 2017/6/6.
//
//

#import <Foundation/Foundation.h>
#import "WDDetailContainerViewModel.h"

@class WDDetailModel;

@interface WDFetchAnswerContentHelper : NSObject

// 初始化创建的，不能由外界赋值
@property (nonatomic, strong, readonly) WDDetailModel *detailModel;

// 销毁的时候需要设置为nil
@property (nonatomic, copy) WDFetchRemoteContentBlock fetchContentBlock;

// 初始化
- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj;

// 获取回答内容信息
- (void)fetchContentFromRemoteIfNeededWithComplete:(WDFetchRemoteContentBlock)block;

@end
