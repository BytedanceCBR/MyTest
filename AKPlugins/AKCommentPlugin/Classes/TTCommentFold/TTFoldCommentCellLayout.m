//
//  TTFoldCommentCellLayout.m
//  Article
//
//  Created by muhuai on 21/02/2017.
//
//

#import "TTFoldCommentCellLayout.h"
#import <TTBaseLib/TTLabelTextHelper.h>
#import <TTBaseLib/TTBaseMacro.h>
#import <TTBaseLib/TTDeviceUIUtils.h>



@interface TTFoldCommentCellLayout ()
@property (nonatomic, assign) CGFloat cellWidth;
@end

@implementation TTFoldCommentCellLayout

- (instancetype)initWithCommentModel:(id<TTCommentModelProtocol>)model cellWidth:(CGFloat)cellWidth {
    self = [super init];
    if (self) {
        _cellWidth = cellWidth;
        [self layoutWithModel:model];
    }
    return self;
}

+ (NSArray<TTFoldCommentCellLayout *> *)arrayWithCommentModels:(NSArray<id<TTCommentModelProtocol>> *)models cellWidth:(CGFloat)cellWidth {
    if (SSIsEmptyArray(models)) {
        return @[];
    }
    
    NSMutableArray<TTFoldCommentCellLayout *> *layouts = [[NSMutableArray alloc] initWithCapacity:models.count];
    
    for (id<TTCommentModelProtocol> model in models) {
        if (![model conformsToProtocol:@protocol(TTCommentModelProtocol)]) {
            NSAssert(NO, @"%s:%d", __FUNCTION__, __LINE__);
            continue;
        }
        TTFoldCommentCellLayout *layout = [[TTFoldCommentCellLayout alloc] initWithCommentModel:model cellWidth:cellWidth];
        [layouts addObject:layout];
    }
    
    return layouts.copy;
}

- (void)layoutWithModel:(id<TTCommentModelProtocol>)model {
    CGFloat rightMargin = [TTDeviceUIUtils tt_newPadding:17.f];
    self.avatarViewFrame = CGRectMake([TTDeviceUIUtils tt_newPadding:15.f], [TTDeviceUIUtils tt_newPadding:15.f], [TTDeviceUIUtils tt_newPadding:36.f], [TTDeviceUIUtils tt_newPadding:36.f]);
    self.nameViewFrame = CGRectMake(CGRectGetMaxX(self.avatarViewFrame) + [TTDeviceUIUtils tt_newPadding:10.f], CGRectGetMinY(self.avatarViewFrame) + 1.f, self.cellWidth - CGRectGetMaxX(self.avatarViewFrame) - [TTDeviceUIUtils tt_newPadding:10.f] - rightMargin, 20.f);
    
    self.contentAttriString = [TTLabelTextHelper attributedStringWithString:model.commentContent fontSize:[TTDeviceUIUtils tt_newFontSize:17.f] lineHeight:[TTDeviceUIUtils tt_padding:26.f] lineBreakMode:NSLineBreakByTruncatingTail];
    CGFloat contentHeight =[TTLabelTextHelper heightOfText:model.commentContent fontSize:[TTDeviceUIUtils tt_newFontSize:17.f] forWidth:CGRectGetWidth(self.nameViewFrame) forLineHeight:[TTDeviceUIUtils tt_padding:26.f]];
    self.contentLabelFrame = CGRectMake(CGRectGetMinX(self.nameViewFrame), CGRectGetMaxY(self.nameViewFrame) + [TTDeviceUIUtils tt_newPadding:2.f], CGRectGetWidth(self.nameViewFrame), contentHeight);
    
    self.timeLabelFrame = CGRectMake(CGRectGetMinX(self.nameViewFrame), CGRectGetMaxY(self.contentLabelFrame) + [TTDeviceUIUtils tt_newPadding:9.f], CGRectGetWidth(self.nameViewFrame), [TTDeviceUIUtils tt_newPadding:16.f]);
    self.cellHeight = CGRectGetMaxY(self.timeLabelFrame) + [TTDeviceUIUtils tt_newPadding:15.f];
}
@end
