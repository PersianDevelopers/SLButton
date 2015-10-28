//
//  SLButton.m
//  Ali Pourhadi
//
//  Created by Ali Pourhadi on 2015-09-28.
//  Copyright © 2015 Ali Pourhadi. All rights reserved.
//

#import "SLButton.h"

@interface SLButton ()
@property (strong,nonatomic) UIActivityIndicatorView *activity;
@property (strong, nonatomic) NSString *currentText;
@property CGRect currentBounds;
@property CGFloat currentCornerRadius;
@end

@implementation SLButton

- (void)awakeFromNib {
    self.animationDuration = 0.3;
    self.disableWhileLoading = YES;
}

- (void)showLoading {
    _isLoading = YES;
    [self addActivityIndicator];
    [self setCurrentData];
    [self clearText];
    [self disableButton];
    [self deShapeAnimation];
    [self setNeedsDisplay];
}

- (void)addActivityIndicator {
    self.activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:(UIActivityIndicatorViewStyleGray)];
    [self setFrameForActivity];
    [self.activity setHidden:NO];
    [self.activity startAnimating];
    [self.activity setCenter:self.center];
    [self.superview addSubview:self.activity];
}

- (void)setCurrentData {
    [self setCurrentText:self.currentTitle];
    [self setCurrentBounds:self.bounds];
    [self setCurrentCornerRadius:self.layer.cornerRadius];
}

- (void)clearText {
    [self setTitle:@"" forState:UIControlStateNormal];
}

- (void)disableButton {
    if (self.disableWhileLoading)
        [self setEnabled:NO];
}

- (void)deShapeAnimation {
    CABasicAnimation *sizing = [CABasicAnimation animationWithKeyPath:@"bounds"];
    sizing.duration= (self.animationDuration * 2) / 5.0;
    if (self.bounds.size.width > self.bounds.size.height)
        sizing.toValue= [NSValue valueWithCGRect:CGRectMake(self.layer.bounds.origin.x, self.layer.bounds.origin.y, self.layer.bounds.size.height, self.layer.bounds.size.height)];
    else
        sizing.toValue= [NSValue valueWithCGRect:CGRectMake(self.layer.bounds.origin.x, self.layer.bounds.origin.y, self.layer.bounds.size.width, self.layer.bounds.size.width)];
    sizing.removedOnCompletion = FALSE;
    sizing.fillMode = kCAFillModeForwards;;
    [self.layer addAnimation:sizing forKey:@"de-scale"];

    CABasicAnimation *shape = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    shape.beginTime = CACurrentMediaTime() + (self.animationDuration * 2) / 5.0;
    shape.duration = (self.animationDuration * 3) / 5.0;
    shape.toValue= @(self.layer.bounds.size.height / 2.0);
    shape.removedOnCompletion = FALSE;
    shape.fillMode = kCAFillModeForwards;;
    [self.layer addAnimation:shape forKey:@"de-shape"];
}

- (void)reShapeAnimation {
    CABasicAnimation *shape = [CABasicAnimation animationWithKeyPath:@"cornerRadius"];
    shape.duration = (self.animationDuration * 3) / 5.0;
    shape.toValue= @(self.currentCornerRadius);
    shape.removedOnCompletion = FALSE;
    shape.fillMode = kCAFillModeForwards;;
    [self.layer addAnimation:shape forKey:@"re-shape"];
    
    CABasicAnimation *sizing = [CABasicAnimation animationWithKeyPath:@"bounds"];
    sizing.beginTime = CACurrentMediaTime() + (self.animationDuration * 3) / 5.0;
    sizing.duration= (self.animationDuration * 2) / 5.0;
    sizing.toValue= [NSValue valueWithCGRect:self.currentBounds];
    sizing.removedOnCompletion = FALSE;
    sizing.fillMode = kCAFillModeForwards;;
    [self.layer addAnimation:sizing forKey:@"re-scale"];
}

- (void)hideLoading {
    _isLoading = NO;
    [self.activity removeFromSuperview];
    [self reShapeAnimation];
    [self reEnable];
    [self performSelector:@selector(resetText) withObject:nil afterDelay:self.animationDuration];
}

- (void)reEnable {
    [self setEnabled:YES];
}

- (void)resetText {
    [self setTitle:self.currentText forState:UIControlStateNormal];
}

- (void)setFrameForActivity {
    [self.activity setCenter:self.center];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    [self setFrameForActivity];
}
@end
