class Task {
  int id;
  String title;
  DateTime date;
  String priority; // low , medium , high or null
  int status; // 0 => task incomplete or 2 => task completed
  Task({this.date, this.priority, this.status, this.title});
  Task.withId({this.id, this.date, this.priority, this.status, this.title});
  Map<String, dynamic> toMap() {
    final map = Map<String, dynamic>();
    if (id != null) {
      map['id'] = id;
    }
    map['title'] = title;
    map['date'] = date.toIso8601String();
    map['priority'] = priority;
    map['status'] = status;
    return map;
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task.withId(
      id: map['id'],
      title: map['title'],
      date: DateTime.parse(map['date']),
      priority: map['priority'],
      status: map['status'],
    );
  }
}
