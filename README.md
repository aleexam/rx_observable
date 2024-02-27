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

## Additional information

TODO: Tell users more about the package: where to find more information, how to
contribute to the package, how to file issues, what response they can expect
from the package authors, and more.
