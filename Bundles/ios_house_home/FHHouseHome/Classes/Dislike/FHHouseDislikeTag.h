//
//  FHHouseDislikeTag.h
//  FHHouseHome
//
//  Created by 谢思铭 on 2019/7/23.
//

#import <UIKit/UIKit.h>
#import "FHHouseDislikeWord.h"

@interface FHHouseDislikeTag : UIButton

@property(nonatomic,strong)FHHouseDislikeWord *dislikeWord;

- (void)refreshBorder;

+ (CGFloat)tagHeight;

- (CGFloat)tagWidth;

@end
