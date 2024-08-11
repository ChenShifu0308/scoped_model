import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:scoped_model/scoped_model.dart';

void main() {
  testWidgets('MultiScopedModel can notify children',
      (WidgetTester tester) async {
    final counterModel = CounterModel();
    final searchModel = SearchModel();

    final widget = TestWidget(counterModel, searchModel);

    await tester.pumpWidget(widget);

    counterModel.increment();

    await tester.pumpWidget(widget);

    expect(counterModel.listenerCount, 1);
    expect(find.text('1'), findsOneWidget);

    searchModel.setSearch('search');
    await tester.pumpWidget(widget);

    expect(searchModel.listenerCount, 1);
    expect(find.text('search'), findsOneWidget);
  });
}

class CounterModel extends Model {
  int _counter = 0;

  int get counter => _counter;

  void increment() {
    // First, increment the counter
    _counter++;

    // Then notify all the listeners.
    notifyListeners();
  }
}

class SearchModel extends Model {
  String _search = '';

  String get search => _search;

  void setSearch(String search) {
    _search = search;

    notifyListeners();
  }
}

class TestWidget extends StatelessWidget {
  final CounterModel counterModel;
  final SearchModel searchModel;
  final bool rebuildOnChange;

  const TestWidget(this.counterModel, this.searchModel,
      [this.rebuildOnChange = true]);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MultiScopedModel(
        models: [counterModel, searchModel],
        // Extra nesting to ensure the model is sent down the tree.
        child: Container(
          child: Column(
            children: [
              ScopedModelDescendant<CounterModel>(
                rebuildOnChange: rebuildOnChange,
                builder: (context, child, model) {
                  return Text('${model.counter}');
                },
              ),
              ScopedModelDescendant<SearchModel>(
                rebuildOnChange: rebuildOnChange,
                builder: (context, child, model) {
                  return Text(
                    model.search,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
