# YapModel

YapModel is an lightweight ActiveRecord implementation on top of [YapDatabase](https://github.com/yaptv/YapDatabase). The syntax is borrowed from Ruby on Rails and inspired by [ObjectiveRecord](https://github.com/mneorr/ObjectiveRecord).

## Prerequisite

You'll need to understand [how YapDatabase work](https://github.com/yaptv/YapDatabase/wiki) before using this library.

## Synopsis

### Create / Save / Delete

```objective-c
Person* john = [Person create];
john.name = @"John";
[john save];
[john delete];

[Person create:@{
  @"name": @"John",
  @"age": @12,
  @"member": @NO
}];
```

### Finders

```objective-c
// Find all objects
NSArray* people = [Person all];

// Get an object by key
Person* john = [Person find:@"uuid"];

// Iterate with all objects and find the object matching the filter
NSArray* people = [Person where:^BOOL(Person* person) {
    return person.age < 30;
}];

// Find using secondary Index
Person *johnDoe = [Person findWithIndex:@"idx" 
                                  query:@"WHERE name == ? AND surname == ?", @"John", @"Doe"];

```

### Transaction

You can simply use the shorthand methods, or use your own transaction.

```objective-c
// Shorthand method
[Person create:@{@"name": @"Leo"}];

// equivalent
[[[YapModelManager sharedManager] connection] readWriteTransactionWithBlock:^(YapDatabaseReadWriteTransaction* transaction){
  [Person create:@{@"name": @"Leo"} withTransaction:transaction];
}];
```

Using `trasaction:` method on ``YapModelObject`` you can run multiple shorthands method in the same transaction:

```objective-c
Person* john = [Person transaction:^{
  Person* john = [Person create:@{@"name": @"Leo"}];
  john.name = @"John";
  [john save];
}];
```

### Aggregation

```objective-c
// count all Person entities
NSUInteger personCount = [Person count];

// count people named John
NSUInteger johnCount = [Person countWithIndex:@"index" query:@"WHERE name = 'John'"];
```

## NSCoding

YapModel include [AutoCoding](https://github.com/nicklockwood/AutoCoding) for automatic NSCoding. This should just work but you
should check [AutoCoding](https://github.com/nicklockwood/AutoCoding) to understand how it work, and override the NSCoding/NSCopying methods if needed.

## License 

MIT License.