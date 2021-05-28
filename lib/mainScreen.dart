import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FirstScreen extends StatefulWidget {
  static const String id = '/firstscreen';
  @override
  _FirstScreenState createState() => _FirstScreenState();
}

class _FirstScreenState extends State<FirstScreen> {
  int bitsEnderecamento = 1;
  int bitsOffset = 1;
  int blocosMemoria = 1;
  int algoSel = 0;

  setSelectedRadio(int val) {
    setState(() {
      algoSel = val;
    });
  }

  @override
  void initState() {
    setSelectedRadio(1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    var openSans = GoogleFonts.openSans(
        fontSize: 24, color: Colors.blue[600], fontWeight: FontWeight.w600);
    return Scaffold(
      body: Container(
        height: height,
        width: width,
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(child: child, opacity: animation);
                },
                child: Text('Iniciando MMU',
                    style: GoogleFonts.openSans(
                        fontSize: 46,
                        color: Colors.blue,
                        fontWeight: FontWeight.w800))),
            SizedBox(
              height: 52,
            ),
            Container(
              width: width * 0.8,
              height: 250,
              decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10)),
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Quantidade de bits de endereçamento virtual: ',
                          style: openSans),
                      Text('Quantidade de bits de OffSet (deslocamento): ',
                          style: openSans),
                      Text('Quantidade de blocos de memória:', style: openSans),
                    ],
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Row(
                        children: [
                          IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                if (bitsEnderecamento - 1 >= 1) {
                                  setState(() {
                                    bitsEnderecamento--;
                                  });
                                }
                              }),
                          Text(bitsEnderecamento.toString(),
                              style: GoogleFonts.openSans(
                                  fontSize: 18, color: Colors.black)),
                          IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  bitsEnderecamento++;
                                });
                              }),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                if (bitsOffset - 1 >= 1) {
                                  setState(() {
                                    bitsOffset--;
                                  });
                                }
                              }),
                          Text(bitsOffset.toString(),
                              style: GoogleFonts.openSans(
                                  fontSize: 18, color: Colors.black)),
                          IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  bitsOffset++;
                                });
                              }),
                        ],
                      ),
                      Row(
                        children: [
                          IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                if (blocosMemoria - 1 >= 1) {
                                  setState(() {
                                    blocosMemoria--;
                                  });
                                }
                              }),
                          Text(blocosMemoria.toString(),
                              style: GoogleFonts.openSans(
                                  fontSize: 18, color: Colors.black)),
                          IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  blocosMemoria++;
                                });
                              }),
                        ],
                      )
                    ],
                  )
                ],
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin:
                    EdgeInsets.symmetric(vertical: 24, horizontal: width * 0.1),
                child: ButtonBar(
                  alignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      children: [
                        Radio(
                          value: 1,
                          groupValue: algoSel,
                          activeColor: Colors.blue,
                          onChanged: (val) {
                            setSelectedRadio(val);
                          },
                        ),
                        Text('FIFO',
                            style: GoogleFonts.openSans(
                                fontSize: 24,
                                fontWeight: algoSel == 1
                                    ? FontWeight.w700
                                    : FontWeight.w500))
                      ],
                    ),
                    SizedBox(
                      width: 18,
                    ),
                    Row(
                      children: [
                        Radio(
                          value: 2,
                          groupValue: algoSel,
                          activeColor: Colors.blue,
                          onChanged: (val) {
                            setSelectedRadio(val);
                          },
                        ),
                        Text('LRU',
                            style: GoogleFonts.openSans(
                                fontSize: 24,
                                fontWeight: algoSel == 2
                                    ? FontWeight.w700
                                    : FontWeight.w500))
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Container(
                margin:
                    EdgeInsets.symmetric(vertical: 24, horizontal: width * 0.1),
                width: width * 0.2,
                height: 50,
                child: ElevatedButton(
                    style: ButtonStyle(),
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, '/mmuhome',
                          arguments: {
                            'bitsEnderecamento': bitsEnderecamento,
                            'bitsOffset': bitsOffset,
                            'blocosMemoria': blocosMemoria,
                            'algoSel': algoSel
                          });
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                          'Iniciar MMU',
                          style: GoogleFonts.openSans(),
                        ),
                        Icon(Icons.arrow_forward_outlined)
                      ],
                    )),
              ),
            )
          ],
        ),
      ),
    );
  }
}
