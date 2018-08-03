//
//  WDListTagImageView.h
//  TTWenda
//
//  Created by wangqi.kaisa on 2018/1/3.
//

#import <TTImage/TTImageView.h>

/*
 * 1.3 可显示标签的图片展示类（目前仅供列表页使用）
 */

typedef NS_ENUM(NSInteger, WDTagImageViewPosition)
{
    WDTagImageViewPositionBottom = 0,             //默认右下角
    WDTagImageViewPositionTop = 1,                //可选右上角
};

@interface WDListTagImageView : TTImageView

- (void)setTagLabelText:(NSString *)text;

- (void)setTagLabelText:(NSString *)text position:(WDTagImageViewPosition)position;

- (void)setExtraCount:(NSString *)extraCount;

@end
