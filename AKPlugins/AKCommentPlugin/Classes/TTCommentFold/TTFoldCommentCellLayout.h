//
//  TTFoldCommentCellLayout.h
//  Article
//
//  Created by muhuai on 21/02/2017.
//
//

#import <Foundation/Foundation.h>
#import "TTCommentModelProtocol.h"

@interface TTFoldCommentCellLayout : NSObject
@property (nonatomic, assign) CGRect avatarViewFrame;
@property (nonatomic, assign) CGRect nameViewFrame;
@property (nonatomic, assign) CGRect contentLabelFrame;
@property (nonatomic, assign) CGRect timeLabelFrame;

@property (nonatomic, strong) NSAttributedString *contentAttriString;

@property (nonatomic, assign) CGFloat cellHeight;

- (instancetype)initWithCommentModel:(id<TTCommentModelProtocol>)model cellWidth:(CGFloat)cellWidth;

+ (NSArray<TTFoldCommentCellLayout *> *)arrayWithCommentModels:(NSArray<id<TTCommentModelProtocol>> *)models cellWidth:(CGFloat)cellWidth;
@end
