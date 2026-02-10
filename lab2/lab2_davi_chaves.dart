void main() {
  print("hello from lab2_davi_chaves");

  Horse horse1 = Horse("Bob", 4, "m", 5, 7);
  print("horse1");
  horse1.show();
  Horse horse2 = Horse("Jane", 3, "f", 6, 2);
  print("horse2");
  horse2.show();
}

class Horse {
  String name;
  int age;
  String sex;
  int wins;
  int secondPlaces;

  double? rating;

  Horse(this.name, this.age, this.sex, this.wins, this.secondPlaces) {
    rating = calculateRating();
  }

  double calculateRating() {
    if (age < 2) {
      return 0;
    }
    return (wins * 2 + secondPlaces) / (age - 1);
  }

  void show() {
    print("name: $name");
    print("age: $age");
    print("sex: $sex");
    print("wins: $wins");
    print("secondPlaces: $secondPlaces");
    print("rating: $rating");
  }
}
