//
//  TTVVideoDetailCollectService.h
//  Article
//
//  Created by pei yun on 2017/4/21.
//
//

#import <Foundation/Foundation.h>
#import "Article.h"
#import "TTVArticleProtocol.h"

@class TTVVideoDetailCollectService;
@protocol TTVVideoDetailCollectServiceDelegate <NSObject>

@optional
/**
 *  显示一个提示及icon的tip
 *
 *  @param manager 当前的manager
 *  @param tipMsg  需要提示的字符串
 */
- (void)detailCollectService:(TTVVideoDetailCollectService *)collectService showTipMsg:(NSString *)tipMsg icon:(UIImage *)image buttonSeat:(NSString *)btnSeat;

//- (void)detailCollectService:(TTVVideoDetailCollectService *)collectService showTipMsg:(NSString *)tipMsg icon:(UIImage *)image;

@end

@interface TTVVideoDetailCollectService : NSObject

@property (nonatomic, strong) NSDictionary *gdExtJSONDict;
//@property (nonatomic, strong) Article *article;
@property (nonatomic, strong) id<TTVArticleProtocol> originalArticle;
@property (nonatomic, weak) id<TTVVideoDetailCollectServiceDelegate> delegate;

- (void)changeFavoriteButtonClicked:(double)readPct viewController:(UIViewController *)viewController;

- (void)changeFavoriteButtonClicked:(double)readPct viewController:(UIViewController *)viewController withButtonSeat:(NSString *)iconSeat;

@end
