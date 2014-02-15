# YapModel

YapModel is an ActiveRecord implementation on YapDatabase.

## Synopsis

### Create / Save / Delete

```
Person* john = [Person create];
john.name = @"John";
[john save]
[john delete];

[Person create:@{
  @"name": @"John",
  @"age": @12,
  @"member": @NO
}];
```

## Finders

```
NSArray* people = [Person all];

// Get an object by Key
Person* john = [Person get:@"uuid"];

// Iterate with all objects and find the object mating query
NSArray *people = [Person where:@{ 
                      @"age" : @18,
                      @"member" : @YES,
                      @"state" : @"NY"
                  }];

// Write your own NSPredicate
NSPredicate *membersPredicate = [NSPredicate  predicateWithBlock:^BOOL(Person *person, NSDictionary *bindings) {
    return person.isMember == YES;
}];
NSArray *members = [Person where:membersPredicate];

// Find using secondary Index
Person *johnDoe = [Person findWithIndex:@"idx" 
                                  query:@"name == ? AND surname == ?", @"John", @"Doe"];

```

### Aggregation

```
// count all Person entities
NSUInteger personCount = [Person count];

// count people named John
NSUInteger johnCount = [Person countWhere:@"name == 'John'"];
```