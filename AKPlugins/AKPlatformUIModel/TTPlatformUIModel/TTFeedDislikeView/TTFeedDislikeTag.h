//
//  ExploreDislikeTag.h
//  Article
//
//  Created by Chen Hong on 14/11/20.
//
//

#import <UIKit/UIKit.h>
#import "TTFeedDislikeWord.h"

@interface TTFeedDislikeTag : UIButton

@property(nonatomic,strong)TTFeedDislikeWord *dislikeWord;

- (void)refreshBorder;

//+ (CGFloat)tagHeight;

@end
