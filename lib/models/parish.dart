class Parish {
  int id;
  String name;

  Parish(this.id, this.name);

  static List<Parish> getParishes() {
    return <Parish>[
      Parish(1, "Clarendon"),
      Parish(2, "Kingston"),
      Parish(3, "St.Elizabeth"),
    ];
  }
}
