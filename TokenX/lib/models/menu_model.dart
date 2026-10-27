class DailyMenuItem {
  final int weekday; // 1 = Monday, 6 = Saturday, 7 = Sunday
  final String dayName;
  final String nonVegFood;
  final String vegFood;
  final bool isAvailable;

  const DailyMenuItem({
    required this.weekday,
    required this.dayName,
    required this.nonVegFood,
    required this.vegFood,
    this.isAvailable = true,
  });
}

class MenuModel {
  static const List<DailyMenuItem> weeklyMenu = [
    DailyMenuItem(
      weekday: DateTime.monday,
      dayName: 'Monday',
      nonVegFood: 'Chicken 65',
      vegFood: 'Gobi 65',
    ),
    DailyMenuItem(
      weekday: DateTime.tuesday,
      dayName: 'Tuesday',
      nonVegFood: 'Chicken Biryani',
      vegFood: 'Mushroom Biryani',
    ),
    DailyMenuItem(
      weekday: DateTime.wednesday,
      dayName: 'Wednesday',
      nonVegFood: 'Fish Fry',
      vegFood: 'Soya 65',
    ),
    DailyMenuItem(
      weekday: DateTime.thursday,
      dayName: 'Thursday',
      nonVegFood: 'Chicken Fried Rice',
      vegFood: 'Paneer Fried Rice',
    ),
    DailyMenuItem(
      weekday: DateTime.friday,
      dayName: 'Friday',
      nonVegFood: 'Fish Gravy',
      vegFood: 'Paneer Gravy',
    ),
    DailyMenuItem(
      weekday: DateTime.saturday,
      dayName: 'Saturday',
      nonVegFood: 'Mutton Biryani',
      vegFood: 'Paneer Biryani',
    ),
    DailyMenuItem(
      weekday: DateTime.sunday,
      dayName: 'Sunday',
      nonVegFood: 'No Special Food Available Today',
      vegFood: 'No Special Food Available Today',
      isAvailable: false,
    ),
  ];

  static DailyMenuItem getForWeekday(int weekday) {
    return weeklyMenu.firstWhere(
      (m) => m.weekday == weekday,
      orElse: () => weeklyMenu.last,
    );
  }

  static DailyMenuItem getForDate(DateTime date) {
    return getForWeekday(date.weekday);
  }

  static bool isSpecialFoodDay(DateTime date) {
    return date.weekday >= DateTime.monday && date.weekday <= DateTime.saturday;
  }

  static String getFoodItem(DateTime date, String category) {
    final item = getForDate(date);
    if (!item.isAvailable) return 'No Special Food';
    if (category.toLowerCase().contains('non')) {
      return item.nonVegFood;
    }
    return item.vegFood;
  }
}
