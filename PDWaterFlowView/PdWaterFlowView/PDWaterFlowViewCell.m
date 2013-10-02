//
//  PDWaterFlowViewCell.m
//  PDWaterFlowView
//
//  Created by pandara on 13-9-30.
//  Copyright (c) 2013年 pandara. All rights reserved.
//

#import "PDWaterFlowViewCell.h"

@implementation PDWaterFlowViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _highLightColor = [UIColor redColor];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTheCell:)];
        [self addGestureRecognizer:tapGesture];
        
        _highLightView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        _highLightView.backgroundColor = [UIColor clearColor];
        [self addSubview:_highLightView];
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    _highLightView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
}

- (id)initWithReuseID:(NSString *)reuseID
{
    self.reuseID = reuseID;
    return [self initWithFrame:CGRectMake(0, 0, 100, 100)];
}

- (void)tapTheCell:(UITapGestureRecognizer *)tapGesture
{
    if ([self.delegate respondsToSelector:@selector(selectCellWithCellIndex:)]) {
        [self.delegate selectCellWithCellIndex:_indexInAll];
    }
    
    [self setState:PDWaterFlowViewCellStateHighLight];
    [UIView animateWithDuration:0.3f delay:0.2f options:UIViewAnimationOptionCurveEaseOut animations:^{
        _highLightView.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {}];
}

//- (void)setCustomHeight:(CGFloat)customHeight
//{
//    CGRect frame = self.frame;
//    frame.size.height = customHeight;
//    self.frame = frame;
//}

- (void)setIndexInColumn:(int)index
{
    _indexInColumn = index;
}

- (int)getIndexInColumn
{
    return _indexInColumn;
}

- (void)setIndexInAll:(int)index
{
    _indexInAll = index;
}

- (void)setHighLightColor:(UIColor *)hightColor
{
    _highLightColor = hightColor;
}

- (void)setState:(PDWaterFlowViewCellState)cellState
{
    switch (cellState) {
        case PDWaterFlowViewCellStateHighLight:
        {
            _highLightView.backgroundColor = _highLightColor;
        }
            break;
        case PDWaterFlowViewCellStateNormal:
        {
            _highLightView.backgroundColor = [UIColor clearColor];
        }
            break;
        default:
            break;
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
