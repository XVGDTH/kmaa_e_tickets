class TestClass {
  const TestClass({required this.test});

  final bool test;

  void printResult() {
    if (test == true) {
      print('test is true');
    } else if (test == false) {
      print('test is false');
    }
  }
}

void main() {
  const testClass = TestClass(test: true);
  testClass.printResult();
}
