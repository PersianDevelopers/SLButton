//
//  SLButton.m
//  Ali Pourhadi
//
//  Created by Ali Pourhadi on 2015-09-28.
//  Copyright © 2015 Ali Pourhadi. All rights reserved.
//

#import "SLButton.h"
#import <objc/runtime.h>

@interface SLButton ()
{
	void(^classBackgroundBlock)();
	void(^classMainBlock)();
}
@property (strong,nonatomic) UIActivityIndicatorView *activity;
@property (strong, nonatomic) NSString *currentText;
@property CGRect currentBounds;
@end

@implementation SLButton

static char overviewKey;

@dynamic actions;

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
    shape.toValue= @0;
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

#pragma mark - Block Action

- (void)setComplationBlock:(void(^)())block forControlEvents:(UIControlEvents)controlEvents {
	if ([self actions] == nil)
		[self setActions:[[NSMutableDictionary alloc] init]];
	
	[[self actions] setObject:[block copy] forKey:[NSString stringWithFormat:@"%lu",(unsigned long)controlEvents]];
	
	// You can manage other control events with if/else
	if (controlEvents == UIControlEventTouchUpInside)
		[self addTarget:self action:@selector(doTouchUpInside:) forControlEvents:controlEvents];
}

- (void)setActions:(NSMutableDictionary*)actions {
	objc_setAssociatedObject (self, &overviewKey,actions,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary*)actions {
	return objc_getAssociatedObject(self, &overviewKey);
}

- (void)doTouchUpInside:(id)sender {
	[self showLoading];
	
	void(^block)();
	block = [[self actions] objectForKey:[NSString stringWithFormat:@"%lu",(unsigned long)UIControlEventTouchUpInside]];
	block();
	
	NSLog(@"In the doTouchUpInside Methode");
	
	// for example in order to show animation use a sample second.
	[sender performSelector:@selector(hideLoading) withObject:nil afterDelay:3.0];
	
	// If you know your block wont be complated immediately, you can comment
	// the performSelector and uncomment line below.
	// [self hideLoading];
}

#pragma mark - Background and Main Block

- (void)setBackgroundBlock:(void(^)())backgroundBlock MainThreadBlock:(void(^)())mainThreadBlock forControlEvents:(UIControlEvents)controlEvents {
	
	classBackgroundBlock = backgroundBlock;
	classMainBlock = mainThreadBlock;
	[self addTarget:self action:@selector(performActionBlock) forControlEvents:controlEvents];
}

- (void)performActionBlock {
	
	__weak typeof(self) weakSelf = self;
	
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{

		classBackgroundBlock();

		// If you then need to execute something making sure
		// it's on the main thread (updating the UI for example)
		dispatch_async(dispatch_get_main_queue(), ^{

			[weakSelf showLoading];
			
			classMainBlock();
			
			[weakSelf performSelector:@selector(hideLoading) withObject:nil afterDelay:3.0];
		});
	});
}

@end
