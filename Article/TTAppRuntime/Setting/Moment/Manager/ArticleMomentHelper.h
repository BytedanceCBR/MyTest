//
//  ArticleMomentHelper.h
//  Article
//
//  Created by Zhang Leonardo on 14-5-26.
//
//  动态的帮助类

#import <Foundation/Foundation.h>
#import "ArticleMomentModel.h"
#import "ArticleMomentProfileViewController.h"
#import "ArticleDetailHeader.h"
#import "NewsDetailLogicManager.h"

@interface ArticleMomentHelper : NSObject

//根据model打开文章详情页或者段子
+ (void)openGroupDetailView:(ArticleMomentModel *)model goDetailFromSource:(NewsGoDetailFromSource)fSource;

+ (void)openMomentProfileView:(SSUserModel *)model navigationController:(UINavigationController *)naviController from:(NSString *)from;


/**
 *  判断服务端返回的moment dict 是否合法
 *
 *  @return YES:合法
 */
+ (BOOL)momentDictValid:(NSDictionary *)dict;
/**
 *  判断是否支持
 *
 *  @param itemType item类型
 *
 *  @return item type
 */
+ (BOOL)supportMomentType:(MomentItemType)itemType;

/**
 *  动态列表最大显示的字数
 *
 *  @return 动态列表最大显示的行数
 */
+ (NSUInteger)maxLineOfCommentInMomentList;

/**
 *  设置动态列表最大显示的字数
 *
 *  @param number 设置动态列表最大显示的行数
 */
+ (void)setMaxLineOfCommentInMomentList:(NSUInteger)number;

@end
