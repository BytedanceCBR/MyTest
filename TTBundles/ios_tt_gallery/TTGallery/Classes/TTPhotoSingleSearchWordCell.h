//
//  TTPhotoSingleSearchWordCell.h
//  Article
//
//  Created by 邱鑫玥 on 2017/4/1.
//
//

#import <UIKit/UIKit.h>
@class TTPhotoSearchWordModel;
/**
 * 相关图集出单搜索词时显示的cell样式
 */
@interface TTPhotoSingleSearchWordCell : UICollectionViewCell

@property (nonatomic, strong, readwrite) TTPhotoSearchWordModel *searchWordItem;

@end

