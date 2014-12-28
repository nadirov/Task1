//
//  ViewController.h
//  Task1
//
//  Created by Saibhan on 12/23/14.
//  Copyright (c) 2014 Saibhan Nadirov. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController 

@property (strong, nonatomic) IBOutlet UIImageView *sourceImage;
@property (strong, nonatomic) IBOutlet UITableView *tableView;

- (IBAction)ChoosePicture:(UIButton *)sender;
- (IBAction)Rotate:(UIButton *)sender;
- (IBAction)InvertColors:(UIButton *)sender;
- (IBAction)Mirror:(UIButton *)sender;




@end

