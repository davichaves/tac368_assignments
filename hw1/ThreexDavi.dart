void main() {
  print("hello from hw1_davi_chaves");

  print('=== Maximum values and Length for starting numbers 1-100 ===');
  for (int i = 1; i <= 100; i++) {
    ThreeX sequence = ThreeX(i);
    print('Start: $i -> Max: ${sequence.max}');
    print('Start: $i -> Length: ${sequence.length}');
    print('Sequence: ${sequence.sequence}');
  }
}

class ThreeX {
  late final List<int> sequence;
  late final int max;
  late final int length;

  ThreeX(int start) {
    var (seq, maxVal) = generateSequence(start);
    sequence = seq;
    max = maxVal;
    length = seq.length;
  }

  static (List<int>, int) generateSequence(int x) {
    List<int> seq = [x];
    int maxVal = x;

    while (x != 1) {
      if (x % 2 == 1) {
        x = 3 * x + 1;
      } else {
        x = x ~/ 2;
      }
      seq.add(x);
      if (x > maxVal) {
        maxVal = x;
      }
    }

    return (seq, maxVal);
  }
}
