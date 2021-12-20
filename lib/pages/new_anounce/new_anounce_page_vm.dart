import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:campus_traveller/core/core.dart';
import 'package:campus_traveller/core/enums/loading_enums.dart';
import 'package:campus_traveller/core/models/anounce_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class NewAnouncePageVm extends ChangeNotifier {
  late BuildContext context;
  late GlobalKey<FormState> formKey = GlobalKey<FormState>();

  String? path;

  String? errorMessage;

  LoadingProcess status = LoadingProcess.done;
  late TextEditingController titleController, linkController, detailController;
  NewAnouncePageVm({required this.context}) {
    titleController = TextEditingController();
    linkController = TextEditingController();
    detailController = TextEditingController();
  }

  void save() async {
    sendToServer();
  }

  void selectPhoto() async {
    ImageSource? source;
    await showDialog(
        context: context,
        builder: (_) => AlertDialog(
              title: const Text('Kaynak Seç'),
              content: const Text('Resmi seçeceğiniz kaynağı belirtiniz'),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      source = ImageSource.camera;
                      Navigator.pop(context, 'dialog');
                    },
                    child: const Text('Kamera')),
                ElevatedButton(
                    onPressed: () {
                      source = ImageSource.gallery;
                      Navigator.pop(context, 'dialog');
                    },
                    child: const Text('Galeri'))
              ],
            ));

    XFile? pickedFile = await ImagePicker().pickImage(source: source!);
    path = pickedFile?.path;
    print(path);
    notifyListeners();
  }

  void sendToServer() async {
    try {
      status = LoadingProcess.loading;
      notifyListeners();
      if (formKey.currentState!.validate()) {
        String? image;
        if (path != null) {
          image = File(path!).readAsStringSync(encoding: utf8);
        }

        AnounceModel model = AnounceModel(
            anounceLink: linkController.text,
            date: DateTime.now(),
            detail: detailController.text,
            id: Random().nextInt(99999999),
            image: image ??
                '''data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAkgAAAGDCAYAAADQ2e9FAAAgAElEQVR4Aezc4a6c2XEr7Dhw7v/GjHNDsePP3HseieKs9XZvjcb4fngBLVaxSFZ1T04geJzzl//3//7fP//7v//7v/7z/vML/OcX+M8v8J9f4D+/wH9+gf/8Av/5BT5/gb/+3//933/97//+79u/xz//+c//+stf/vKD/h1uNdv/EPiv5jbHw/hutczTPFze7bvwtA63uc2r4Ve1N5+cRlqYWdc3bfh871fa9m/d3tR5fsuehe/+K9p4n97mvrM/ee3bvmddu6O5W72ZvLB9v1Ir/5aZvXl+p4/mX380v7fRNNK0r+db07/Lf1V3y0/O0+xpz8134pvrevPdE9x/BmbNy4LRnN4fnXdmsvL6jvT42+xn9Zv77nc56XAwt+alz+sbV/Mh+O2PnnWdcfep8zr3g/iJPzr3lb21p7o5WTiIf0Ja+I62Na98mefl96Nt7lVWe37FP4Pel/qvf/3rf338R0eOOmG4/gg5aXeWntcX0NMumtPvXG8e/dbhbo82mA+tvXw96zpzntZuHY/X+ubNm+s68+15GqPpHWbNdU7X0dLB9YffT/uSt5k93zpaeevb3i2d4U7a9DJP+tZlvtrt7Vpf71HbJyO8WVCWmh4uvz3dIt0NV5/e9+kZf3PqnW3feZn5xE8bXJ18fGvNcOnpzBZ7Hh9vsGfru/Xtb80pr7XmzcXffd/TfHQ9058yX/ni7de58fq0Rh1t62983xB99+1J3ftSd/5tnzz+zewMM7j37I69gc9O2XT46MzUuyt867tfPrM8ez67+5/R0cpyD/7mdidsnazmUsuGreu6tZ3BF6716sxpguGbe8qiha1VZ5ZPv1tPC3k+/oK0R2YYoWN73rUQuvXJoOs+nvSnZ8dpbmZX+83g+rePlzbo07pw6c1O+5pLzQ9Pc5lm6Vt/qnG0bpMRDHd7/Jl3zSPvqZcdDT1u75KTOS0uiMvcPTBcnj5ID3ueGh/UB+Pl19Omz9M3fk6+/yn3O/NZudEcrk6/8+5Ty4u++/4OmyWjMXpZ0Dz+zsPDzFN3hhm+NeF85Np5yuhZcvLkf3bf/+RvD45KvzeYL9I3b/8iDb7vsC8a82A0ev4gHoZrXfh88lrzQfzrD1oafLA5dVAdTfw+7WlN+H1y7G/MLH1n9Dy1OZQHW5/d+s7sm/D87VFnJqe9t5pWtv6kp7HrhHzJ6VtSt5/uxJl1/tanPlznpe47zPDR76MJr4ZPv42caE96XjN699nX866jkwF7rqZL77N6PXQL/PafIAnN4CQ+cSftSYeDlm+P92W6P9U3P635YuZPO9rfv0vz6qd59mYedEN8ejfIWE20ZqnzNq89tPA0C9cZtEG8OvvoU+ell0sfvuv0/WS0zxz3pJENedPnyVDjP4a/zWk6A9c6GTgok9+95rAz1cGbnk9+ej4zPXRD5u1L3X3mPKlv70mTWT5PuetvvRnMDcnSw76t5+Gj8dneXT2nCZ6efLtlBH0yw28GH8y86+6T0Vl0zUVvV3ia8KdHs7r0cvhow+8sGp7OooN0NM2nxgfV9jdm9kqfeee3Hy8D2mnOg9fD5tcjM1ozd584Gtnb89gpX5+5/ObkLdLaA1snB/ZMbXbKS2bnpo6ORwZsLS64npOuOXug2zrzVvdtXbsD2kejN29M/e0/QWIItqnrGPRPmFk+nUWfjDw9xMXTn/Dpva53RpNMuWo9jR3pM5P7pOOF7cMtyl0+fc9SJ88n885P/fTilwdb3/Pl0/e8azfcMjuLVl7f3P6u25+aJxp59LjWmHUOXXPqkz4zmXTQDfr2qyHNDU86HIz3dovc1uKCeP7uu+65unNOdftP8+Wi54E03dsPaba/8aesaNuvhu2JVh/0Cd+Pt7mtW6Pe7JsnOh7IG0/X5p21XOfRdQYuuLweRrP5ehp9tE+Pnia+5rqOJj3uhtG9uz/aPPpkqsPbkTrPDE8fPjX+U/17f/jWdJ3Z5od79Xrv5t28dEE7o+3v0fVtR/uj51Hbn36fG5pvTg2jS21H+s79Sn3L6V3J3/dXhCMgvgP6oOX18ORvLllPu2i/irfMvn01vSP3tzazm36/a+fcPK1J3Rl24xr7ps1+1dvZGbjGzlG74clLAzvzVss31/eezsM3xwtl6L+Cye0dsuyDm9me04xP3pPG7OaxK7po9JAv8+XSm0MauLw98jKnCZfXuZ/M77nOp4fJU8uTA/nTt57P3G033jw5PKnz5H52n/1yZsH2y6UPqqM1bx8O9s3N8Zunz7OftjnazNQfpt/+wEHezsLxmbXHLFzrW0vTXGo93FyZ8bdGHp6OxhxPt3z0rUndXGqZp9nm9Z7O7Qye1uLsSK9upJNHhw/u7NaHd6M6SL97W9Mz+t7duX1bat6t6XjT29l1uN7JR6NfjVyZcpqPd+8L9+0vSG1uYUTeLg5/4uj7gM6/+W578TD+W326p7Vu6wye6E5vb6fj66ytT3lPms6kC7pBHfTWs/1NF95vs2hfZ+Hiw/dv0XU0T6+zotNDXNBt6p7h4svn3SdzsfPUMju/v6saRr/3rLd7+U/oThp978zslNvcrU5OZ9Hh9PbD5mnNGlfXfXTxhstHzb/a1eiffE+z257wu1tO8+G85nE86d26Ne36W3/TyDIPuol/c90E28u/nvA3rnPsXn1rMvOWv91s9y0/eZ1F/7THDPLIgZnvrLnUtHTh8vAQ9zH87Q+eaDxcsL07N4OZr0dWZq2jbX69mXlyYPjOa55nNdGf3nq3P3lO2e3rOtr09p9mm/fxr9iQwbw1frKfP4QaWpY+dfdy8NvLWOyM1HywuXjDtydcehxf+Dw9pE3v86n8/p3Dd157OzMaWnr5MlvfXGoefN/T9Wr5FuXc0Pcw7z61vOXpG6NpXc+27tz1bE7PzfiT23M8Tg/dYa6/oX3BzuA/cWbJzLw14Xqe/unx8uh5wt9mNMH19UwtB+JvmEyfaNzS/sz1XUefPo8v9WrC9WuPOnM71Jnd5tH0LH0eDn6yP/6ZPTvf+znwfVtm3ashb3aEg3gYfu/A8ciE8ZrJ6R1PefStSa3vHam75z1xmYWXs1o8pG/PzmiCPUvfr2dbuxWaB3GnLLqeqdvXdebx8WamXm/rdqaHpx1mjTJX3xozd/FEY9b6raPhSb2ezm0v/qTHwfi65u281ZitVv/tL0gdzAQjZginD8anf8qQFYyOVm5nyaSlSd91+tvbHU++1cp0k97NevPOpunMrnlfYWd2HZ/ernDqxczeeXyrDW9fz3A3X7Q9o5fRs3CZL0d7wtXGf8qgg5uFh5l3nd7ty+uDTxq6ZO07zXyXaHve3695uuV2lxthz3khTffh8MHMei6Pxl1B+ubay4PjCfbredfRpE+OXTu/5bRHDq27Fs2D7XcD/oTNpT7dKQeu5+SL1idzb2/Xm9sR9DrHPL7WRNv9KVdeZuZquJrW2W3PO7PkyeYLpzYLl5e+Z+rP6eef4eiC/fDNdd15vDydS0cjQw/pzINmwVPdWjtv3Po7s3fLuenbl13tTb/z1sjkoYX8kF4f9HhoYM/tCZda/+0vSAZMQcEMQeG47lMLxnduODyUyWdv92oems4L9/TsuWk6O5r09vLQQJmro1/kC3Z90snOTD6Pvn1mzaW2C/b8Xa73qYO789Yv7y63ZC4Xt5rmeyb7lT86n846cZ1Pa48e+h1O+2mC67e3eXWyfDrDDrqenTh7e5ZaDn+4V5po+6bOaJ6u8+yB9sH233x4nmSpzcJ1Fk2wH19zajPY3zPc9vH1ztbQQjt4gvb0DB9f5nm3HR/Df/2xOd3bD3mgHTC82g28+KCZnO5bl3lmMrrHmetp7Emf13Mzuz4Vn3/Kay462p53Ztf0PMlK3Zpw6ZtvfeZ5OFpc+z6E8wcf2u7lMzdLfcrtuXp1+sz3I9du2vDeeuzpeer2qoM+9LBzw8nl1fcs9Wm+mvZm1u8vf/vb3/75j3/8o7ljbdFpuLOv9KtNfnOp8/pLnLgP0b/+aG+4Vz3fz+Desf1T5t5Fuxmt2xnPDdsbzVf8673twL+b/U7uTXPj3dB40obL6/9Zao/65n3ynTzJu/F2Lf6RGzdL/5UbVrv9q8zW32oZsHXNpT795q2/1XKesL1Pup6dPE9cz7p+lZl567vmDZd3+o1oFjun69XpV7N9dOHyvnJH9LLgculltia813zqfq+80baf949wneked8i/4bv6vu/JQwdPe59mr/S9u3O2Tk5+g+ZP2cs95be2f9/ecavb25rl/+d//ufz/8w/A8e0SL0htLAPjOcr/Wr5O3s16Zdz6/Kv+vjskvEu7h3bP+XsXbTL63PjKf/pdt7OXs5scXVPe+I93baZdCe+ud1tFt4d0GzxlPErb+z9qXtfz5rfG0/9r7xRfjJzU9+lbky9WvfTJVO9mFnrb3V0efHL+GS+Z/Pi6btXy+HR83SPC7Ye3/eoYTTeiTODN014s6A7+IL41prj2heOr5HnCeXRbI//Kropvludme/RmvDeiQ+XT7zmcoInvvPaIwvSNcrjg61R0wbzaCHdaXbz8Damjn49m5t5tD69n7c5fvrg6fVuOavFx991evmpPX4YT+r2bk0Lk7Wezs/Mp7P4gvhv/4oNwSiwxakthnTpvVNGz6PT0+p7Jg/S6k/Ymq3p8UGv6xt30rzS3jwnHuefhexgOPPlu4/mpKPZ2fZ0QbNg78eftM2poz95zIM977o1qfuOnXV/2/nEt3/r/WfSvVq2vjP2O73q27v1ybvcetL3XerGrTvTTM724Z/0mefFRycDmgdpUuel5119ehzdp+vzz56HoU3d+puu9fHk4fbOz+nnnKY5erNgODwtzNxnufSdo08Wnkd+8+qgWgZf+L6vda1RN9LanZnbIC4YPY8eNh/u9GTa1x5cfHhcelzXu6NnXUcni+eUh6NZNE+WGrY2HL734qKlwW0vr/1d08sK9l0nf2vNF5Nhjx16/u5xm8Pb8+U6J7PWdh0dLd2H+F9/fPsLEqKNqRmhACg8fWtucxr76GDP1TAaOreZbV761qeOlr5zaIPmuO3Dez3DQft2T89Tywi2Fk8Pm0+th8noHL5gNJnRhnulpeHVB/NkdQ7uU/F9R/NdR9d+vuDqwtHurPto6OLxlo8nn9Z2Dt8Ttl6OXD68ftG8s6LpXr3a9Dge2t3zzpxH5lMWbZC+udTrpwufeufxhKfTN5488qJ79W7++J5mfVO07jx5MvfM6cM3t7ru6XCLt/kTv7P0J86u3G0OzU64Gr+bHH28uM4x35xowmVOw9c5fJAG8u88/XI8wZ3p7T75aTpHlu8Ao+2aFxdsDo/rHSeu51vLWl6/8+Tj7Gru5Is+H3qaRpnNqZ980Zif7pDhhu7Vi7/7C9LT8ZYL0fOcvphjHLwavEx6GH49tLfZTS/TfLHz+rv1PrW7n3TyeU5IA6OR3XpcdL2TD7ana/5wr7SraW9nrs7slB+u+a75YM+6Ng+G39n2rb/VX8nxu2+WvTDzrlf/NF9f913LcBPE0+LTd23et5mH67q9eEib3qe51HbtXC6MNk/2DaPpTJ7NoZOTPi89PwzP39zJG21ez3ib7/mH4cFjp5xG3kbZQdrM9allqnnCr4cm6NHIgeby7NRn3tquV8uzGjuaD8dvvn34ePLpmT5zO1Pn6fla+6n4/FMe/fYnP42c9D7R79vd20e/XO+Q3Vw8+NS3F01eo1048+0/jL/9YRb04Vtd5r2DPtyJl0PXfWer6YKtXX538f/uL0gGJxRilj7PcrXlH8Pf5qvVQ94TyjGzj1dP133XOzeD5u+g3fDJIx8+aTPbzPia6/qUZQ88Za6vtTvrfU+6+Hbefde948a3puuv6k/eU8aJa+87dWfkd+v+5N959+/U/tnA3eGGZN00mZmfdpolW0Zwaz1d9+7CBTc3/XKyYOZ5J+16V8PnBn0wr/2nPpy71cG89soP0jf36fj8E4+TA8PLSB3e7IbR5WXeb3fJDar5aCF+d4angbSNqfNoFjNzb2ZqaL4zOZnnmbvzkz3/8zHbDDnmkM6O7mmCdjc2Hx9vfz8ZnS/DDNKkl9V1c3hc78TRLNq/ulNPm4y8aHz0H4Pf/tiZPugt131qO3kae9Z86v7cdoU//gUp5oTn4/WCcGYWPel4o+k6vRxIk/6mjaZfdOvveeqem8mHrWuOHp6yzE4oCz75d5aeL9nm8J19J01npc6Op0yzvuWUuzmt77q9N57GbohvfJq1zi7Ys603sz07421NuO3p4M6739pOfHoclLs9jzmMLjPzxq6j38wTx3PS2glpu1/ODJoH1Tvb/umWzkjd2p11buvC0y5vduLlnVCemT7YtfzG9ehPKCv3qeGT/kkTX+adKcvvEOyaJ3jy9dxumFm/8DvT987bnvB0crt/8kVv1w1lPiEvTe/HtabnzUfbM17Ys67NO+s0D7d8PMtt37l2wdWmX442aAZ71vXO0y9Hj//2F6STOF/i6Yt0GF1y1JmrLYS8MLp8zNcni46PXr8oZ/lb74ZTLq4zcae82+zJ37Nk9j3JM4fv7j3dshnbd/bTjM4OWr05bD519zSN8mBm6+lZe9WrfyfjKbNnp2x7b8gDb7rmeyc+XDJ2pt/Z7qOTl/lqzE64fpobn/nmby/jV2FusaPrU37fzbO6Gx9d+9t32nvKuflP2s7v+iva+KK/7e3cdzT0txtkBPPZ3dvTy33C2872yLO/Z/w7w9PK0MMbb7454U+e6GjNYTxmcHOa39n2ndt1dHmb9cl+/zMePphp16f+e8Lvd5y8y/GHN4NmT5jv1d6b9uMvSCv2owTVG5Bwc4el7/rkbR+9nO2zs/V9g2z7ViczHrn8q6WBmcu1h5dGvqzmV2uG503ffvMTuqnvudX85sHbHpp4Uu9ns/T0jdnh7U57mlfztaZrO3Cn32I17sD7/snoHDoc5DM/IW3fj2tMvb38m7f1vRsfzneSddLJN9t+vZnfcm9837R59kZjN6Ttnt7sqX+aucnN8Mmzs9Ndvkfn2cW/fXi+1nQGjXnjene2/enu1aR3597RM5r2q3emDyazc814b9i388B4ut6M9vZsPdvTnvzRhs9nfdvLaWxNZzTfdbz2dU7Xmed1Xno5zeMyz9MHu/6cfv6JT2fX1t1vFn/z0eNT5+nd2/quaen0/On3Zda3Z97+ruXY2d6PvyAJIkzvY7FZ93zhhAZpM1e3L/Xm6+k726wzzOk3sz206w/ffhnhljeT0fknLv7W9A3Nb66sviH60z20MmjsuiEdnxx3NdLK0rfXTE40OGimh+Fl4oJdr/ep57vlhm/NZvWsa7rF3N73x7PfP5wsNZTX/dY0wcz66WFmvZ/Wjd3j4lWbdx4uiIfNtW7r0w5eu4Ndtyd896d8HG36rt18yrG3Pc2d+M7L3MPrg7uTBp40/K3JTX3XzrrnX1xN8prrfnlZrcFF23zXZrTwxMe33uib48c3br07tpeV/JMXF5/nFp7m1cH2dN9817xPuWZuiKfr2x48rb0w87ztP9nf/+mO6HlutZ1SulffvPHI56eNN593X+eoG+XK+/afIIUgTG1xc/ggftGseT+AL2IWbV76nu38U/V50+rNGmWFU8PWpbYL4tzUfGbJWW57GcGffcnMx912wOSqV/Nq5/pWL6930LS3deaLNHw9x8GepeZNTdNc+Lxwy6fn+VR9/nnien6rNz+6ZPnw3faa/2o87fMd+2ac/Xt3+ujbc8rmh60P9+Rxw3rwfVNzdgXxzak393QLTe+S2zOc7O6fbqCX1Xjz0fA+4d79pN2ZPdA9kH775eO/aWiDq9k+mlNWdLRu7bzmmudpLvVtR2Z58uJfbc8+1Z9/9q5XvIzWbU0DN3/7+JvrerOfevteaU66r+xcbfddu+O0L7PVpl/upJMLb/nm8If/BAkZtPhVUOaraS51sqC6d9mHW3/4cP38KPA0szOz1nXdvq7b2/y/u37n1nc0/Zv6Dny335au53Li5V9d813TvYtf8a52+/4Ovf/Gt+adun+Xd/TR7O7t38256fo32Oztk9H67k/azMPfPJk/vVvmk+fVzC2L7cvstPv0Xdr31doNfPrs2f1m0XbNG1xPz9Q3b8/fyaFfdPvTntPsaedJ33tP8xMXT+/puvV4GF/P1eb66E7v1TyeX6U57f8Z7uke37tzo3/ytFZ9yjF7wvjyse9Vzml+4nan/OX1Mn74T5AMT7iBAsKbnbjM8HJbv7NoOjN9NDz64Kt32v3KY977cMHlT/e3/t36lnPjN7d1W6d/untnye6MnqfuvrXLP924s845zXDZkdv6PrMn5HvSPM1efbdX83fu3YyTBwff/V6y29ff98ZHw9v6Jz4zeevhu2We9Dy32bu8m067cdHQyd0e37ia7rvOHrviz6znndl1e5r/ar37n/x711e8nRvf6Xvidk97U7+arz6932u9eNje1p7mrVW3B/dH8GlvduXzpMnuVzc9zZ+y25daD//I9+bN/qcb6GBr3YHT0/4M/vCfICXQR5hl6TPTw9aHa55HVvfx5UWvbuzcD+H80XO+SLZ2z2nWGeYnzgzSBOU3l7pf9123RjaudepGdftwbpK1PR2kkxU+HnNIlx63KKO1uM7Etd+duM3QP+na2zUvDvZNuMauZQTD9yx1Z9GsR8+7us41a+3ukAdby98zvx2OZvlbzvKdo45m71yfHvI2mkGz7tWQ5oT7HWnWu7r+Lq3tuj3h9UG1fUHenuNu2H71avFPePKcuNyGf8ozo4Xh1f098bhgPx5cz81OGB2+d8jpmXnP2k8LV8938pi1R85ia9U3TXbls6/1qWlS7yzevrlruTyventg6ztX3glx8abuXh7s2am206zvwtkDw5t1zfuXv/3tb//8+9///u1HdcxizA5gtuTE81veHrN38OR3y23/ad67et68+mn+NOt7ZP0s9p7Ueb/yN/zZu558r+7s7/SU8ytm7+56V+em1qshzVdwvdvfsla3fft6poZ02+ODZrC5rdPfHj+86Zpf7fbRLqeHnad+Z7aa7ruWGTzxJ661Pe+6c/+sOvvynv53+NPup3tvsxv/7h5++OTb2Xqe+p1t1p/R2xnM6/+db2Zv97c62p5tv7OnebT73v2fm92z/ea6I/j0G5x8P8Od7vnrX//6+f9RpC/5FNxHRnf6sdpvHt/mm7W+653v7u67Xt9TZs+6lgEz67r3nXzN/ZG693Tdt3R+81vH3xnt+yN170nOn7Ejub0ndfc7T5/XtzzpW/fpfP6TPplq+Oz8nLoFrnf7V5mbo2+fzMzUPU9943vWmtR2Nb+50bRub+g5XTLUm71932c3DcQ3/sysPV3fcn2HnnfdGbS49Lh41LBztv6Kxr5kpG5v17vjnb6zW2+P/KC6dV3zhJMLW/eqlmPfZnTf9atceSfdztLjFvmzu/fTmf8qPO1obuv0Pm6g+cqNPMlYn3732NdI+5RD/6SlWfz4V2wh++AVdU/XmMX61N23N7VZ8NX7ijZZuYFns923/PbR+ZjxPt1MA3n/KGZn773lN3+rf/YW+6Gc3vPEvTOjOeHuSd+3bH/KaG7zetZ172g+9WbQwtXr+eBJf+L4IX+w9fjomk/f2iddtO+8dzKiOe11m4z06le7eW+6p3nPuj5lvXvPyRtu/bd90a12/ebwtpPvtouvc96p+aD89u5Mvxjv+tLLXH36k+dJf8rAZdfuNzvhz+6Rtbu+st9uHn2wc2+1G06YDHnm2+NP2Dsz735zehZtz3e2ffTezrrvOvrtZbyaZe6+b39BanPXhM1t3Yeo+SBP5suZQRmLr3z8J3zHe9I0555T/q/gelfnZe/uXm33XXfOjW9N6ptub3jS9kwezCxv+0/2zmeeG+Jziwy9jEae5p7qWyaeNz3Ofohv7anGNcrAbRYerv6Jp5UZxPFBGv0TbgYvjDe1vvWpu492e77MvBOXWbxPM/6Trn1qyLfY866jS3/bs9rO/SPfPznr7+yuc8PTHa3tWv5605vRrybz5uiX54ftCcd3m69++/jCnXiZwdNdPLD1X6l9h8XNsOeVbn3peXa2fPfZZyffq57uhOulOe0xC958NK/mdIvr6+8erf7xL0gbEiMONpc6L+EWBKPVfyq+/5mZLPh9+lnd+NWl3z16+JRF07nNPXl53tGctPH1LpoTl9ny3av3FrzsG65On7ynzJ51zQ9ve/GvdObZoeb9FfhuZnRf0f7Mbf0d+zf9StbJ5254ynuaRZ/cU3Zm69UH19cZXSfH40/ftfniauTu7pOPVgZcbfpon+Y80bSua/vkNfIvvrt3fdvvXeZ90xPX3yO67XkXW/fVXSf9aXfvMF9vNHRmQXV8XafvxwuftHyr2Z7uhu/q39X1Ht8jqDbX33Kbp13v9qc9NMHO6fzW3Oonfefe/OG//QUpYf3JcI/PXHDQAbh4cF231rw9XbdPbd45ZtBMfvjbo+15fP3pmdod+t2V/qSRyxe8aVfz1JvJD57e8vS05jeeLt/t9Nv1XB1s7WnH6bfif3XL5vMF7WquefNG+5aTEd73uWlog76b3HB8PZOZuccT7LlaDl371FCGPsiP2x7/pJXrpps2c482iJfTGvXetb08+uBqcPbB5tfTuWYwvn6r7fzotu8c3tY0RxtsTefSuGl7fHBn3ashX/d7Q89O+TLaxxPEw+hT90zuSWPWmHqfneHlr6Zn0djnFn10OLlQRtDrWThe86DsJy0N/WrDh8Of0DxZXcfbzwzXfeq8YOfozT5Ev+nUUIY+uNz20fRvkD5vOb5g30cbvjX6xY/w5Of/iu0f//jHty9sAGO06IR0J+TNbOtwpy+Hi/6k+SBf/LG7+u5Ye75RPTvV4Ty36mH7wm1P9y72Th67N/urvbwb2t2/4e7gvfHmX8XN61uesvijPIoAACAASURBVF7pNveU1Ro1POlx72ham9o/y9Q3/42Px4smr/9ZmcF3cmi/irLhk/8dTfzR5fVv9EEc/qB9pX9392HFH6Z+xe7N2P4PH/knBbgTZk3qvP7n2/OP4S/447Znd//RVe/c3pque3fzXbfmVJ+0y3Xf9eaZwZ1v/0rX865vOdHk/er/ffa02y3R/M//''',
            title: titleController.text);
        await FirebaseFirestore.instance
            .collection('anounces')
            .doc()
            .set(model.toMap);
      } else {
        errorMessage = 'Hata: Lütfen tüm alanları doğru biçimde doldurunuz.';
        throw Exception('Hata: Lütfen tüm alanları doğru biçimde doldurunuz.');
      }
      status = LoadingProcess.done;
      notifyListeners();
    } catch (e, stk) {
      debugPrintStack(stackTrace: stk);
      print(e.toString());
      status = LoadingProcess.error;
      notifyListeners();
    }
  }
}
