//
//  PDWaterFlowViewCell.h
//  PDWaterFlowView
//
//  Created by pandara on 13-9-30.
//  Copyright (c) 2013年 pandara. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum{
    PDWaterFlowViewCellStateNormal,
    PDWaterFlowViewCellStateHighLight,
}PDWaterFlowViewCellState;

@protocol PDWaterFlowViewCellDelegate <NSObject>

- (void)selectCellWithCellIndex:(NSInteger)cellIndex;

@end

@interface PDWaterFlowViewCell : UIView {
    int _indexInColumn;
    int _indexInAll;
    UIColor *_highLightColor;
    UIView *_highLightView;
}

@property (copy, nonatomic) NSString *reuseID;
@property (strong, nonatomic) id <PDWaterFlowViewCellDelegate> delegate;

- (id)initWithReuseID:(NSString *)reuseID;
//- (void)setCustomHeight:(CGFloat)customHeight;
- (void)setIndexInColumn:(int)index;
- (int)getIndexInColumn;
- (void)setIndexInAll:(int)index;

@end
