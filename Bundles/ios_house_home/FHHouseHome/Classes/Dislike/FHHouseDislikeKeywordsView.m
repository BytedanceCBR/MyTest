//
//  FHHouseDislikeKeywordsView.m
//  FHHouseHome
//
//  Created by 谢思铭 on 2019/7/23.
//

#import "FHHouseDislikeKeywordsView.h"

#import "FHHouseDislikeTag.h"
#import "FHHouseDislikeWord.h"
#import "TTDeviceHelper.h"
#import "UIViewAdditions.h"
#import "TTBaseMacro.h"
#import "TTFeedDislikeView.h"

@interface FHHouseDislikeKeywordsView ()

@property(nonatomic,strong)NSMutableArray *tags;
@property(nonatomic,strong)NSMutableArray *tagButtonArray;

@end

@implementation FHHouseDislikeKeywordsView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.tagButtonArray = [NSMutableArray array];
    }
    return self;
}

- (void)refreshWithData:(NSArray *)keywords {
    for (UIView *tag in self.tags) {
        [tag removeFromSuperview];
    }
    
    if (keywords.count == 0) {
        self.height = 0;
        return;
    }
    
    CGFloat x = [self leftPadding], y = 0;
    CGFloat tagWidth = 0;
    
    for (FHHouseDislikeWord *word in keywords) {
        NSString *str = word.name;
        if (!isEmptyString(str)) {
            FHHouseDislikeTag *tag;
            tag = [[FHHouseDislikeTag alloc] initWithFrame:CGRectMake(x, y, tagWidth, [FHHouseDislikeTag tagHeight])];
            tag.backgroundColor = [UIColor clearColor];
            [self.tagButtonArray addObject:tag];
            
            tag.dislikeWord = word;
            [self addSubview:tag];
            [tag addTarget:self action:@selector(toggleSelected:) forControlEvents:UIControlEventTouchUpInside];
            
            tagWidth = [tag tagWidth];
            
            if (x + tagWidth > (self.width - [self leftPadding])) { 
                x = [self leftPadding];
                y += [FHHouseDislikeTag tagHeight] + [self paddingY];
            }
            
            tag.frame = CGRectMake(x, y, tagWidth, [FHHouseDislikeTag tagHeight]);
            x += tagWidth + [self paddingX];
        }
    }
    
    self.height = ((FHHouseDislikeTag *)[self.tagButtonArray lastObject]).bottom;
}

- (void)toggleSelected:(id)sender {
    FHHouseDislikeTag *tag = (FHHouseDislikeTag *)sender;
    tag.selected = !tag.selected;
    tag.dislikeWord.isSelected = tag.isSelected;
    //按钮之间的互斥逻辑
    if(tag.selected){
        for (NSInteger i = 0; i < tag.dislikeWord.exclusiveIds.count; i++) {
            NSInteger exclusiveId = [tag.dislikeWord.exclusiveIds[i] integerValue];
            for (FHHouseDislikeTag *tagBtn in self.tagButtonArray) {
                if([tagBtn.dislikeWord.ID integerValue] == exclusiveId){
                    tagBtn.selected = NO;
                    tagBtn.dislikeWord.isSelected = NO;
                }
            }
        }
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(dislikeKeywordsSelectionChanged)]) {
        [_delegate dislikeKeywordsSelectionChanged];
    }
}

- (NSArray *)selectedKeywords {
    NSMutableArray *array = [NSMutableArray array];
    for (FHHouseDislikeTag *tag in self.tagButtonArray) {
        if (tag.isSelected) {
            [array addObject:tag.titleLabel.text];
        }
    }
    return array;
}

- (BOOL)hasKeywordSelected {
    for (FHHouseDislikeTag *tag in self.tagButtonArray) {
        if (tag.dislikeWord.isSelected) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - size & padding

- (CGFloat)leftPadding {
    return 15.0f;
}

- (CGFloat)paddingY {
    return 10.0f;
}

- (CGFloat)paddingX {
    return 10.0f;
}

@end
