import 'package:flutter_test/flutter_test.dart';
import 'package:tokenx/models/menu_model.dart';

void main() {
  group('Fixed Weekly Menu Requirements', () {
    test('Monday special foods', () {
      final mon = MenuModel.getForWeekday(DateTime.monday);
      expect(mon.nonVegFood, equals('Chicken 65'));
      expect(mon.vegFood, equals('Gobi 65'));
      expect(mon.isAvailable, isTrue);
    });

    test('Tuesday special foods', () {
      final tue = MenuModel.getForWeekday(DateTime.tuesday);
      expect(tue.nonVegFood, equals('Chicken Biryani'));
      expect(tue.vegFood, equals('Mushroom Biryani'));
      expect(tue.isAvailable, isTrue);
    });

    test('Wednesday special foods', () {
      final wed = MenuModel.getForWeekday(DateTime.wednesday);
      expect(wed.nonVegFood, equals('Fish Fry'));
      expect(wed.vegFood, equals('Soya 65'));
      expect(wed.isAvailable, isTrue);
    });

    test('Thursday special foods', () {
      final thu = MenuModel.getForWeekday(DateTime.thursday);
      expect(thu.nonVegFood, equals('Chicken Fried Rice'));
      expect(thu.vegFood, equals('Paneer Fried Rice'));
      expect(thu.isAvailable, isTrue);
    });

    test('Friday special foods', () {
      final fri = MenuModel.getForWeekday(DateTime.friday);
      expect(fri.nonVegFood, equals('Fish Gravy'));
      expect(fri.vegFood, equals('Paneer Gravy'));
      expect(fri.isAvailable, isTrue);
    });

    test('Saturday special foods', () {
      final sat = MenuModel.getForWeekday(DateTime.saturday);
      expect(sat.nonVegFood, equals('Mutton Biryani'));
      expect(sat.vegFood, equals('Paneer Biryani'));
      expect(sat.isAvailable, isTrue);
    });

    test('Sunday special food blackout', () {
      final sun = MenuModel.getForWeekday(DateTime.sunday);
      expect(sun.isAvailable, isFalse);
      expect(MenuModel.isSpecialFoodDay(DateTime(2026, 10, 4)), isFalse); // Oct 4, 2026 is Sunday
    });
  });
}
