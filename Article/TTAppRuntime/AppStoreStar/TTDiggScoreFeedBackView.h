//
//  TTDiggScoreFeedBackView.h
//  Article
//
//  Created by Zichao Xu on 2017/10/16.
//

#import <UIKit/UIKit.h>

@interface TTDiggScoreFeedBackView : UIView

//展现
- (void)show;

//消失
- (void)dismissFinished:(dispatch_block_t)block;

//赞或踩的操作
- (void)refreshActionDiggBlock:(dispatch_block_t)upBlock
                     downBlock:(dispatch_block_t)downBlock
                     cancelBlock:(dispatch_block_t)cancelBlock;

//统计
- (void)setTrackDic:(NSDictionary *)trackDic;

@end
