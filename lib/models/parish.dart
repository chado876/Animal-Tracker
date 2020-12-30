class Parish {
  int id;
  String name;

  Parish(this.id, this.name);

  static List<Parish> getParishes() {
    return <Parish>[
      Parish(1, "Clarendon"),
      Parish(2, "Kingston"),
      Parish(3, "St.Elizabeth"),
      Parish(4, "St.James"),
      Parish(5, "Trelawny"),
      Parish(6, "St.Ann"),
      Parish(7, "St.Mary"),
      Parish(8, "St.Andrew"),
      Parish(9, "St.Thomas"),
      Parish(10, "St.Catherine"),
      Parish(11, "Portland"),
      Parish(12, "Westmoreland"),
      Parish(13, "Hanover"),
      Parish(14, "Portland"),
    ];
  }
}
