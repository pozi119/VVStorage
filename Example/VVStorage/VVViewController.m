//
//  VVViewController.m
//  VVStorage
//
//  Created by pozi119 on 12/25/2019.
//  Copyright (c) 2019 pozi119. All rights reserved.
//

#import "VVViewController.h"

@interface VVViewController ()

@end

@implementation VVViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSCache *cache = [[NSCache alloc] init];
    [cache setObject:@"1" forKey:@"A"];
    if(cache){}
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
