//
//  TTVPlayerTipFinished.h
//  Article
//
//  Created by panxiang on 2017/5/17.
//
//

#import <UIKit/UIKit.h>
typedef void(^FinishAction)(NSString *action);
@class TTVPlayerStateStore;
@protocol TTVPlayerTipFinished <NSObject>
@property(nonatomic, copy)FinishAction finishAction;
@property (nonatomic, strong) TTVPlayerStateStore *playerStateStore;
@end

@interface TTVPlayerTipFinished : UIView<TTVPlayerTipFinished>
@property(nonatomic, copy)FinishAction finishAction;
@property (nonatomic, strong) TTVPlayerStateStore *playerStateStore;
@end
