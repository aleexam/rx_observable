Simple reactive variables and widgets.
Similar to Livedata/observable/mobx, but without code generation and without badcode.

Ideal to use with MVVM like patterns.

## Features

Create reactive variables, listen them, update UI.

## Usage

Just define var like this:

```dart
  var text = "Hello".obs;
```

And use Observer widget to subscribe for changes:

```dart
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          /// Use Observer widget directly to update UI with values
          Observer(text, (v) => Text(v)),
          /// Use extensions which creates same observer widget
          text.observer((v) => Text(v)),
          /// Use big builder version
          Observer.builder(
              observable: text,
              builder: (context, v) {
                return Text(v);
              }
          )
        ],
      ),
    );
```

Update value like this:

```dart
  text.value = "GoodBye";
```

Listen like this:

```dart
    text.listen((v) {
        print("New value is $v");
    });
```

Dispose like this:

```dart
  text.close();
```

## Additional information

More examples:

```dart

    // Listen for 2 or 3 observables in Observer
    Observer3.builder(
        observable: text,
        observable2: text2,
        observable3: text3,
        builder: (context, v1, v2, v3) {
          return Text("$v1 $v2 $v3");
        }
    ),

    // All constructors gives the same result
    var test1 = Observable(25);
    var test2 = Observable<int>(25);
    var test3 = Obs(25);
    var test4 = 25.obs;
    var test5 = ObservableInt(25);
    var test6 = ObservableReadOnly(25); /// You can only read this value
    
    test1.listen((v) {
      if (kDebugMode) { print(v); }
    });
    
    /// Listen observable without UI updating
    /// Also see ObservableConsumer widget to get both
    var widgetListener = ObservableListener(
      observable: test1,
        listener: (v, context) {
          if (kDebugMode) { print(v); }
        },
        child: const SizedBox(),
    );
```
