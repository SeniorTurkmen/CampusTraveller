import 'dart:io';

import 'package:campus_traveller/core/core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'new_anounce_page_vm.dart';

class NewAnouncePage extends StatelessWidget {
  const NewAnouncePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => NewAnouncePageVm(context: context),
      child: Consumer<NewAnouncePageVm>(builder: (_, value, __) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Yeni İlan'),
          ),
          floatingActionButton: FloatingActionButton.extended(
              onPressed: value.save, label: const Text('Kayıt et')),
          body: value.status != LoadingProcess.loading
              ? Column(
                  children: [
                    _imageSection(value, context),
                    Form(
                      key: value.formKey,
                      child: Column(
                        children: [
                          Card(
                            child: TextFormField(
                              controller: value.titleController,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'Lütfen ilan başlığını giriniz.',
                                  labelText: 'Başlık*'),
                              validator: (text) {
                                if ((text == null || text.isEmpty)) {
                                  return 'Başlık boş olamaz';
                                } else if (text.length < 5) {
                                  return 'Başlık 5 karakterden az olamaz!';
                                }
                                return null;
                              },
                            ),
                          ),
                          Card(
                            child: TextFormField(
                              controller: value.linkController,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'İlan linki giriniz',
                                  labelText: 'İlan linki'),
                              validator: (text) {
                                return null;
                              },
                            ),
                          ),
                          Card(
                            child: TextFormField(
                              controller: value.detailController,
                              textInputAction: TextInputAction.next,
                              decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: 'İlan detayı giriniz.',
                                  labelText: 'İlan detayı*'),
                              validator: (text) {
                                if ((text == null || text.isEmpty)) {
                                  return 'Detay boş olamaz!';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                )
              : SizedBox(
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
                ),
        );
      }),
    );
  }

  GestureDetector _imageSection(NewAnouncePageVm value, BuildContext context) {
    return GestureDetector(
      onTap: value.selectPhoto,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        color: Colors.grey[400],
        child: SizedBox(
          height: MediaQuery.of(context).size.height * .3,
          width: double.infinity,
          child: value.path == null
              ? const Center(
                  child: Icon(
                    Icons.photo_filter,
                    size: 75,
                  ),
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(25),
                  child: Image.file(
                    File(value.path!),
                    fit: BoxFit.fitWidth,
                  )),
        ),
      ),
    );
  }
}
