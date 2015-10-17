//
//  ViewController.m
//  SLButtonSample
//
//  Created by Ali Pourhadi on 2015-09-29.
//  Copyright © 2015 Ali Pourhadi. All rights reserved.
//

#import "ViewController.h"
#import "SLButton.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
	
	// Setup SLButton without IB with Action Block
	SLButton *centerButton = [[SLButton alloc]initWithFrame:CGRectMake(0, 0, 200, 60)];
	[centerButton setTitle:@"Center Button" forState:UIControlStateNormal];
	[centerButton setBackgroundColor:[UIColor orangeColor]];
	[centerButton setCenter:self.view.center];
/*
	[centerButton setComplationBlock:^{
		
		// You may want to fetch Data or Update UI etc. which takes along seconds.
		// The process is:
		// Showing Animation will start and then block will be run. Hide Animation
		// will be fired when block action complated.
		
		NSLog(@"In the Block Action");
		
	} forControlEvents:UIControlEventTouchUpInside];
*/
	
	[centerButton setBackgroundBlock:^{
	
		NSLog(@"In the Background Thread");
	
	} MainThreadBlock:^{
		
		NSLog(@"In the Main Thread");

	} forControlEvents:UIControlEventTouchUpInside];
	
	[self.view addSubview:centerButton];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonTapped:(SLButton *)sender {
    [sender showLoading];
    [sender performSelector:@selector(hideLoading) withObject:nil afterDelay:3.0];
}

@end
