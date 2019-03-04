//
//  TTVResolutionSelectView.h
//  Article
//
//  Created by panxiang on 2017/5/24.
//
//

#import <UIKit/UIKit.h>
#import "TTVPlayerControllerState.h"
#import "TTVPlayerContext.h"

@protocol TTVResolutionSelectViewDelegate <NSObject>

- (void)didSelectWithType:(TTVPlayerResolutionType)type;

@end

@interface TTVResolutionSelectView : UIImageView<TTVPlayerContext>
@property (nonatomic, strong) TTVPlayerStateStore *playerStateStore;
@property (nonatomic, weak) id<TTVResolutionSelectViewDelegate> delegate;
- (void)setSupportTypes:(NSArray *)types;
- (CGSize)viewSize;

@end
