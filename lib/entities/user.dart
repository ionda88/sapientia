class User {
  String id = "";
  String ra = "";
  String senha = "";
  String nome = "";
  String curso = "";

  User(
      this.id, this.ra, this.senha, this.nome, this.curso);

  User.empty();

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['ra'] = ra;
    map['senha'] = senha;
    map['curso'] = curso;
    map['senha'] = senha;
    return map;
  }

  factory User.fromMapObject(String id, Map<String, dynamic> map) {
    return User(
      (id),
      (map['ra'] ?? ""),
      (map['senha'] ?? ""),
      (map['nome'] ?? ""),
      (map['curso'] ?? ""),

    );
  }
}


