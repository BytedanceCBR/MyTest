//
//  TTHorizontalHuoShanLoadingCell.h
//  Article
//
//  Created by 邱鑫玥 on 2017/8/1.
//
//

#import <UIKit/UIKit.h>
#import "TSVShortVideoDataFetchManagerProtocol.h"

typedef NS_ENUM(NSUInteger, TTHorizontalHuoShanLoadingCellStyle){
    TTHorizontalHuoShanLoadingCellStyle1, //老的双图卡片样式，标题在图片外面
    TTHorizontalHuoShanLoadingCellStyle2, //新的双图卡片样式，标题在图片里面
};

@interface TTHorizontalHuoShanLoadingCell : UICollectionViewCell

@property (nonatomic, nullable, strong) id<TSVShortVideoDataFetchManagerProtocol> dataFetchManager;
@property (nonatomic, assign, getter=isLoading) BOOL loading;
@property (nonatomic, assign) TTHorizontalHuoShanLoadingCellStyle style;

@end
