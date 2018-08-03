//
//  AKAwardCoinTipModel.h
//  Article
//
//  Created by chenjiesheng on 2018/3/12.
//

#import "TTInterfaceTipBaseModel.h"

typedef NS_ENUM(NSInteger, AKAwardCoinTipType)
{
    AKAwardCoinTipTypeArticle = 0,//在文章场景
    AKAwardCoinTipTypeVideo,//在视频场景
};

@interface AKAwardCoinTipModel : TTInterfaceTipBaseModel

@property (nonatomic, copy)NSString             *title;
@property (nonatomic, assign)NSInteger           coinNum;
@property (nonatomic, copy)NSString             *iconImageName;
@property (nonatomic, assign)AKAwardCoinTipType  tipType;
@end
