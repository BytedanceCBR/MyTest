//
//  TTLayOutPlainRightPicCellModel.h
//  Article
//
//  Created by 王双华 on 16/10/17.
//
//

#import "TTLayOutPlainCellBaseModel.h"

@interface TTLayOutPlainRightPicCellModel : TTLayOutPlainCellBaseModel

//标题与图片居中
- (CGFloat)heightForTitleAndRightPicAndInfoRegionInPlainCellWithTop:(CGFloat)top;
//u11cell 右图标题与图片上对齐
- (CGFloat)heightForTitleAndRightPicAndInfoRegionInUFCellWithTop:(CGFloat)top;

@end

@interface TTLayOutPlainRightPicCellModelS0 : TTLayOutPlainRightPicCellModel

@end

@interface TTLayOutPlainRightPicCellModelS0AD : TTLayOutPlainRightPicCellModel

@end

@interface TTLayOutPlainRightPicCellModelS1 : TTLayOutPlainRightPicCellModel

@end

@interface TTLayOutPlainRightPicCellModelS2 : TTLayOutPlainRightPicCellModel

@end
