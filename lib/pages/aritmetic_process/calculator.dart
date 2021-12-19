import 'dart:math';

import 'package:flutter/material.dart';

class MyCalculator extends StatefulWidget {
  const MyCalculator({Key? key}) : super(key: key);

  @override
  _MyCalculatorState createState() => _MyCalculatorState();
}

class _MyCalculatorState extends State<MyCalculator> {
  String? dersAdi;
  int dersKredi = 1;
  double dersHarfDegeri = 4;
  late List<Ders> tumDersler;
  static int sayac = 0;

  var formKey = GlobalKey<FormState>();
  double ortalama = 0;

  @override
  void initState() {
    super.initState();
    tumDersler = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text("Ortalama Hesapla"),
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (formKey.currentState?.validate() ?? false) {
            formKey.currentState?.save();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: OrientationBuilder(builder: (context, orientation) {
        if (orientation == Orientation.portrait) {
          return uygulamaGovdesi();
        } else {
          return uygulamaGovdesiLandscape();
        }
      }),
    );
  }

  Widget uygulamaGovdesi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        //STATIC FORMU TUTAN CONTAINER
        Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          //color: Colors.pink.shade200,
          child: Form(
            key: formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: "Ders Adı",
                    hintText: "Ders adını giriniz",
                    hintStyle: TextStyle(fontSize: 18),
                    labelStyle: TextStyle(fontSize: 22),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.purple, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.purple, width: 2),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                  ),
                  validator: (girilenDeger) {
                    if (girilenDeger != null && girilenDeger.isNotEmpty) {
                      return null;
                    } else {
                      return "Ders adı boş olamaz";
                    }
                  },
                  onSaved: (kaydedilecekDeger) {
                    dersAdi = kaydedilecekDeger;
                    setState(() {
                      tumDersler.add(Ders(dersAdi!, dersHarfDegeri, dersKredi,
                          rastgeleRenkOlustur()));
                      ortalama = 0;
                      ortalamayiHesapla();
                    });
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Container(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          items: dersKredileriItems(),
                          value: dersKredi,
                          onChanged: (secilenKredi) {
                            setState(() {
                              dersKredi = secilenKredi ?? 0;
                            });
                          },
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 4),
                      margin: const EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.purple, width: 2),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                    ),
                    Container(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<double>(
                          items: dersHarfDegerleriItems(),
                          value: dersHarfDegeri,
                          onChanged: (secilenHarf) {
                            setState(() {
                              dersHarfDegeri = secilenHarf!;
                            });
                          },
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15, vertical: 4),
                      margin: const EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.purple, width: 2),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10))),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        Container(
          margin: const EdgeInsets.symmetric(vertical: 10),
          height: 70,
          decoration: const BoxDecoration(
              color: Colors.blue,
              border: BorderDirectional(
                top: BorderSide(color: Colors.blue, width: 2),
                bottom: BorderSide(color: Colors.blue, width: 2),
              )),
          child: Center(
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                      text: tumDersler.isEmpty
                          ? " Lütfen ders ekleyin "
                          : "Ortalama : ",
                      style:
                          const TextStyle(fontSize: 30, color: Colors.white)),
                  TextSpan(
                      text:
                          tumDersler.isEmpty ? "" : ortalama.toStringAsFixed(2),
                      style: const TextStyle(
                          fontSize: 40,
                          color: Colors.purple,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ),
        ),

        //DINAMIK LISTE TUTAN CONTAINER
        Expanded(
            child: ListView.builder(
          itemBuilder: _listeElemanlariniOlustur,
          itemCount: tumDersler.length,
        )),
      ],
    );
  }

  Widget uygulamaGovdesiLandscape() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
                //color: Colors.pink.shade200,
                child: Form(
                  key: formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Ders Adı",
                          hintText: "Ders adını giriniz",
                          hintStyle: TextStyle(fontSize: 18),
                          labelStyle: TextStyle(fontSize: 22),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.purple, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.purple, width: 2),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                          ),
                        ),
                        validator: (girilenDeger) {
                          if (girilenDeger != null && girilenDeger.isNotEmpty) {
                            return null;
                          } else {
                            return "Ders adı boş olamaz";
                          }
                        },
                        onSaved: (kaydedilecekDeger) {
                          dersAdi = kaydedilecekDeger;
                          setState(() {
                            tumDersler.add(Ders(dersAdi!, dersHarfDegeri,
                                dersKredi, rastgeleRenkOlustur()));
                            ortalama = 0;
                            ortalamayiHesapla();
                          });
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Container(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<int>(
                                items: dersKredileriItems(),
                                value: dersKredi,
                                onChanged: (secilenKredi) {
                                  setState(() {
                                    dersKredi = secilenKredi!;
                                  });
                                },
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 4),
                            margin: const EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.purple, width: 2),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10))),
                          ),
                          Container(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<double>(
                                items: dersHarfDegerleriItems(),
                                value: dersHarfDegeri,
                                onChanged: (secilenHarf) {
                                  setState(() {
                                    dersHarfDegeri = secilenHarf!;
                                  });
                                },
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 15, vertical: 4),
                            margin: const EdgeInsets.only(top: 10),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.purple, width: 2),
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10))),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                      color: Colors.blue,
                      border: BorderDirectional(
                        top: BorderSide(color: Colors.blue, width: 2),
                        bottom: BorderSide(color: Colors.blue, width: 2),
                      )),
                  child: Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                              text: tumDersler.isEmpty
                                  ? " Lütfen ders ekleyin "
                                  : "Ortalama : ",
                              style: const TextStyle(
                                  fontSize: 30, color: Colors.white)),
                          TextSpan(
                              text: tumDersler.isEmpty
                                  ? ""
                                  : ortalama.toStringAsFixed(2),
                              style: const TextStyle(
                                  fontSize: 40,
                                  color: Colors.purple,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          flex: 1,
        ),
        Expanded(
          child: ListView.builder(
            itemBuilder: _listeElemanlariniOlustur,
            itemCount: tumDersler.length,
          ),
        ),
      ],
    );
  }

  List<DropdownMenuItem<int>> dersKredileriItems() {
    List<DropdownMenuItem<int>> krediler = [];

    for (int i = 1; i <= 10; i++) {
//     var aa = DropdownMenuItem<int>(value: i, child: Text("$i Kredi"),)
//     krediler.add(aa);
      krediler.add(DropdownMenuItem<int>(
        value: i,
        child: Text(
          "$i Kredi",
          style: const TextStyle(fontSize: 20),
        ),
      ));
    }

    return krediler;
  }

  List<DropdownMenuItem<double>> dersHarfDegerleriItems() {
    List<DropdownMenuItem<double>> harfler = [];
    harfler.add(const DropdownMenuItem(
      child: Text(
        " AA ",
        style: TextStyle(fontSize: 20),
      ),
      value: 4,
    ));
    harfler.add(const DropdownMenuItem(
      child: Text(
        " BA ",
        style: TextStyle(fontSize: 20),
      ),
      value: 3.5,
    ));
    harfler.add(const DropdownMenuItem(
      child: Text(
        " BB ",
        style: TextStyle(fontSize: 20),
      ),
      value: 3,
    ));
    harfler.add(const DropdownMenuItem(
      child: Text(
        " CB ",
        style: TextStyle(fontSize: 20),
      ),
      value: 2.5,
    ));
    harfler.add(const DropdownMenuItem(
      child: Text(
        " CC ",
        style: TextStyle(fontSize: 20),
      ),
      value: 2,
    ));
    harfler.add(const DropdownMenuItem(
      child: Text(
        " DC ",
        style: TextStyle(fontSize: 20),
      ),
      value: 1.5,
    ));
    harfler.add(const DropdownMenuItem(
      child: Text(
        " DD ",
        style: TextStyle(fontSize: 20),
      ),
      value: 1,
    ));
    harfler.add(const DropdownMenuItem(
      child: Text(
        " FF ",
        style: TextStyle(fontSize: 20),
      ),
      value: 0,
    ));

    return harfler;
  }

  Widget _listeElemanlariniOlustur(BuildContext context, int index) {
    sayac++;
    debugPrint(sayac.toString());

    return Dismissible(
      key: Key(sayac.toString()),
      direction: DismissDirection.startToEnd,
      onDismissed: (direction) {
        setState(() {
          tumDersler.removeAt(index);
          ortalamayiHesapla();
        });
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: tumDersler[index].renk, width: 2),
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(4),
        child: ListTile(
          leading: Icon(
            Icons.done,
            size: 36,
            color: tumDersler[index].renk,
          ),
          title: Text(tumDersler[index].ad),
          trailing: Icon(
            Icons.keyboard_arrow_right,
            color: tumDersler[index].renk,
          ),
          subtitle: Text(tumDersler[index].kredi.toString() +
              " kredi Ders Not Değer: " +
              tumDersler[index].harfDegeri.toString()),
        ),
      ),
    );
  }

  void ortalamayiHesapla() {
    double toplamNot = 0;
    double toplamKredi = 0;

    for (var oankiDers in tumDersler) {
      var kredi = oankiDers.kredi;
      var harfDegeri = oankiDers.harfDegeri;

      toplamNot = toplamNot + (harfDegeri * kredi);
      toplamKredi += kredi;
    }

    ortalama = toplamNot / toplamKredi;
  }

  Color rastgeleRenkOlustur() {
    return Color.fromARGB(150 + Random().nextInt(105), Random().nextInt(255),
        Random().nextInt(255), Random().nextInt(255));
  }
}

class Ders {
  String ad;
  double harfDegeri;
  int kredi;
  Color renk;

  Ders(this.ad, this.harfDegeri, this.kredi, this.renk);
}
