//
//  TTLayoutLoopPicCollectionViewCell.h
//  Article
//
//  Created by 曹清然 on 2017/6/20.
//
//

#import <UIKit/UIKit.h>


@interface TTLayoutLoopPicCollectionViewCell : UICollectionViewCell

@property (nonatomic,strong)TTImageInfosModel *imageModel;

-(void)configureWithModel:(TTImageInfosModel *)imageModel;

@end
