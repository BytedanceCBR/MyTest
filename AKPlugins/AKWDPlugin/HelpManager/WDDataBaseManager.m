//
//  WDDataBaseManager.m
//  Article
//
//  Created by xuzichao on 2016/12/6.
//
//

#import "WDDataBaseManager.h"

@implementation WDDataBaseManager

//问答数据库，与主端分开
+ (NSString *)wenDaDBName
{
    return @"tt_wenda";
}

/*
 * 每次修改模型类中的persistentProperties方法都需要来这里升级版本号
 * 13 feed中添加问答cell
 * 14 问答频道页列表页涨粉
 * 15 问答详情页增加位置记录的功能
 * 16 回答模型类增加原图属性
 * 17 回答模型类增加是否轻回答属性
 */
+ (NSInteger)wenDaDBVersion
{
    return 17;
}

@end
