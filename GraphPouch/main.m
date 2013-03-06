//
//  main.m
//  GraphPouch
//
//  Created by PATRICK LEE on 7/20/12.
//  Copyright (c) 2012 Patrick Lee. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EDValidation.h"

int main(int argc, char *argv[])
{
    // direct distribution/dev mode
    return NSApplicationMain(argc, (const char **)argv);
    
    // receipt validation
    //return EDCheckReceiptAndRun(argc, (const char **)argv);
}
