//
//  ViewController.m
//  ZKLogDemo
//
//  Created by 刘子康 on 2023/12/29.
//

#import "ViewController.h"
#import <ZKLog/ZKLog.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [ZKLog startRecord];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    static NSInteger index = 0;
    NSLog(@"点击了%@次", @(index++));
}

@end
