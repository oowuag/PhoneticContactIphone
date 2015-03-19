//
//  ViewController.m
//  Phonetic
//
//  Created by iOSDev on 15-3-19.
//  Copyright (c) 2015年 ErrorEgg. All rights reserved.
//

#import "ViewController.h"
#import <AddressBook/AddressBook.h>
#import <AddressBookUI/AddressBookUI.h>


@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

static NSString *phonetic(NSString *sourceString) {
    NSMutableString *source = [sourceString mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)source, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)source, NULL, kCFStringTransformStripDiacritics, NO);
    source = [source capitalizedString];    
    return source;
}

- (IBAction)startSort:(id)sender {
    
    // access request
    ABAddressBookRequestAccessWithCompletion(ABAddressBookCreateWithOptions(NULL, nil), ^(bool granted, CFErrorRef error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!granted){
                //4
                UIAlertView *cantAddContactAlert = [[UIAlertView alloc] initWithTitle: @"Cannot Add Contact" message: @"You must give the app permission to add the contact first." delegate:nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
                [cantAddContactAlert show];
                return;
            }
            //5
            //[self addPetToContacts:sender];
        });
    });
    
    // init and get addressbook
    CFErrorRef error = nil; // no asterisk
    ABAddressBookRef addressBook =
    ABAddressBookCreateWithOptions(NULL, &error); // indirection
    // get contact people
    NSArray *arrayOfPeople = (__bridge NSArray *)(ABAddressBookCopyArrayOfAllPeople(addressBook));
    // list all people
    for (id obj in arrayOfPeople) {
        ABRecordRef person = (__bridge ABRecordRef)obj;
        NSMutableString *pinyin = [NSMutableString string];
        NSString *fn = (__bridge NSString *)ABRecordCopyValue(person, kABPersonFirstNameProperty);
        if (fn) {
            [pinyin appendString:phonetic(fn)];
            ABRecordSetValue(person, kABPersonFirstNamePhoneticProperty, (__bridge CFStringRef)phonetic(fn), NULL);
        }
        NSString *ln = (__bridge NSString *)ABRecordCopyValue(person, kABPersonLastNameProperty);
        if (ln) {
            [pinyin appendString:phonetic(ln)];
            ABRecordSetValue(person, kABPersonLastNamePhoneticProperty, (__bridge CFStringRef)phonetic(ln), NULL);
        }
        NSLog(@"%@",pinyin);
    }
    //save
    ABAddressBookSave(addressBook, NULL);
    
}
@end
