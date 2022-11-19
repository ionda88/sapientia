class Livro {
  String id = "";
  String autor = "";
  String url = "";
  String titulo = "";
  String ano = "";
  String genero = "";
  String descricao = "";
  num dtInicio = 0;
  num dtFim = 0;
  String userid = "";

  Livro(
      this.id, this.autor, this.url, this.titulo, this.ano, this.genero, this.descricao, this.dtInicio,this.dtFim,this.userid);

  Livro.empty();

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{};
    map['autor'] = autor;
    map['url'] = url;
    map['titulo'] = titulo;
    map['ano'] = ano;
    map['genero'] = genero;
    map['descricao'] = descricao;
    map['dtInicio'] = dtInicio;
    map['dtFim'] = dtFim;
    map['userid'] = userid;
    return map;
  }

  factory Livro.fromMapObject(String id, Map<String, dynamic> map) {
    return Livro(
      (id),
      (map['autor'] ?? ""),
      (map['url'] ?? ""),
      (map['titulo'] ?? ""),
      (map['ano'] ?? ""),
      (map['genero'] ?? ""),
      (map['descricao'] ?? ""),
        (map['dtInicio'] ?? 0),
        (map['dtFim'] ?? 0),
      (map['userid'] ?? ""),
    );
  }
}


