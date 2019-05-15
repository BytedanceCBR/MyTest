//
//  TTVideoShareMovie.h
//  Article
//
//  Created by panxiang on 16/11/24.
//
//

#import <Foundation/Foundation.h>
#import "ArticleVideoPosterView.h"
#import "TTVideoTabBaseCellPlayControl.h"
@interface TTVideoShareMovie : NSObject
@property (nonatomic ,weak)UIView *movieView;
@property (nonatomic ,weak)TTVideoTabBaseCellPlayControl *playerControl;
@property (nonatomic ,strong)UIView <TTVideoDetailHeaderPosterViewProtocol> *posterView;
@property (nonatomic ,assign)BOOL hasClickRelated;
@property (nonatomic ,assign)BOOL hasClickPrePlay;
@property (nonatomic ,assign)BOOL isAutoPlaying;//feed自动播放
@end
