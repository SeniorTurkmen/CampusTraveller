import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../core/core.dart';
import '../../core/models/anounce_model.dart';
import '../pages.dart';
import 'anounce_page_vm.dart';

class AnouncePage extends StatefulWidget {
  const AnouncePage({Key? key}) : super(key: key);

  @override
  _AnouncePageState createState() => _AnouncePageState();
}

class _AnouncePageState extends State<AnouncePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('İlanlar')),
        floatingActionButton: getIt<UserNotifier>().currentUser!.isAdmin
            ? FloatingActionButton(
                onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const NewAnouncePage())),
                child: Icon(Icons.add),
              )
            : null,
        body: ChangeNotifierProvider(
            create: (_) => AnouncePageVm(),
            child: Consumer<AnouncePageVm>(
                builder: (_, value, __) => StreamBuilder(
                    stream: value.fS.collection('anounces').snapshots(),
                    builder: (_,
                        AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                            snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox(
                          height: MediaQuery.of(context).size.height,
                          width: double.infinity,
                          child: const Center(
                            child: SizedBox(
                              height: 35,
                              child: CircularProgressIndicator(
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        );
                      } else if (snapshot.connectionState ==
                              ConnectionState.done ||
                          snapshot.connectionState == ConnectionState.active) {
                        if (snapshot.hasData &&
                            snapshot.data!.docs.isNotEmpty) {
                          return ListView(
                              physics: const ClampingScrollPhysics(),
                              shrinkWrap: true,
                              children: snapshot.data!.docs.map((e) {
                                AnounceModel anounceModel =
                                    AnounceModel.fromMap(e.data());
                                return Card(
                                  child: SizedBox(
                                    height:
                                        MediaQuery.of(context).size.height * .1,
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(25),
                                          child: Image.network(
                                            anounceModel.image!,
                                            fit: BoxFit.fitHeight,
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(e.data()['title'] ??
                                                  'dsfmdl'),
                                              Text(e.data()['anounce_link'])
                                            ],
                                          ),
                                        ),
                                        Text(DateFormat('EEE, dd.MM.yyy')
                                            .format(anounceModel.date)),
                                      ],
                                    ),
                                  ),
                                );
                              }).toList());
                        } else if (getIt<UserNotifier>().currentUser!.isAdmin) {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height,
                            width: double.infinity,
                            child: const Center(
                                child: Text('Lütfen yeni bir anons ekleyin')),
                          );
                        } else {
                          return SizedBox(
                            height: MediaQuery.of(context).size.height,
                            width: double.infinity,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  'Şuan Herhangi bir anons bulunmamaktadır. Lütfen daha sonra yeniden deneyin',
                                  textAlign: TextAlign.center,
                                ),
                                ElevatedButton.icon(
                                    onPressed: () => Navigator.pop(context),
                                    icon: const Icon(Icons.arrow_back_ios_new),
                                    label: const Text('Geri Gön'))
                              ],
                            ),
                          );
                        }
                      } else {
                        log(snapshot.connectionState.toString());
                        return SizedBox(
                          height: MediaQuery.of(context).size.height,
                          width: double.infinity,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Text(
                                'Bir hata oluştu lütfen daha sonra tekrar deneyiniz.',
                                textAlign: TextAlign.center,
                              ),
                              ElevatedButton.icon(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.arrow_back_ios_new),
                                  label: const Text('Geri Gön'))
                            ],
                          ),
                        );
                      }
                    }))));
  }
}
