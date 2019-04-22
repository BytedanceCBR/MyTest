//
//  TTMovieResolutionSelectView.h
//  Article
//
//  Created by xiangwu on 2016/12/2.
//
//

#import <UIKit/UIKit.h>
#import "ExploreVideoSP.h"

@protocol TTMovieResolutionSelectViewDelegate <NSObject>

- (void)didSelectWithType:(ExploreVideoDefinitionType)type;

@end

@interface TTMovieResolutionSelectView : UIImageView

@property (nonatomic, weak) id<TTMovieResolutionSelectViewDelegate> delegate;

- (void)setSupportTypes:(NSArray *)types currentType:(ExploreVideoDefinitionType)currentType;
+ (NSString *)typeStringForType:(ExploreVideoDefinitionType)type;
- (CGSize)viewSize;

@end
