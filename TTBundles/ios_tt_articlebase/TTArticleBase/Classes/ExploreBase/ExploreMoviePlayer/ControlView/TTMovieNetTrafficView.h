//
//  TTMovieNetTrafficView.h
//  Article
//
//  Created by xiangwu on 2016/11/10.
//
//

#import <UIKit/UIKit.h>

@interface TTMovieNetTrafficViewModel : NSObject

@property (nonatomic, assign) NSInteger videoDuration;
@property (nonatomic, assign) NSInteger videoSize;
@property (nonatomic, assign) BOOL isInDetail;

@end

@interface TTMovieNetTrafficView : UIView

@property (nonatomic, copy) dispatch_block_t backBlock;
@property (nonatomic, copy) dispatch_block_t continuePlayBlock;
@property (nonatomic, strong) TTMovieNetTrafficViewModel *viewModel;

@end
