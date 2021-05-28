import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class MMUHome extends StatefulWidget {
  final Map args;
  MMUHome(this.args);

  static const String id = '/mmuhome';

  @override
  _MMUHomeState createState() => _MMUHomeState();
}

class _MMUHomeState extends State<MMUHome> {
  //date formatter
  final f = new DateFormat('hh:mm:ss');

  //page controller
  int page = 0;

  //controller
  TextEditingController enderecoBin = TextEditingController();
  TextEditingController offsetBin = TextEditingController();
  ScrollController _scrollControllerFila = new ScrollController();

  //variaveis bits
  int bitsEnderecamento;
  int bitsOffset;
  int blocosMemoria;
  int algoSel;
  int tamanhoTabela;
  int tamanhoRAM;
  int blocosUsando = 0;

  //variaveis
  String prefInput = 'binario';
  int selectedRadio = 1; // 1 - Binario | 2 - Decimal

  //novo endereço virtual de entrada
  int novoEndereco;

  //matrizes
  List<int> using = [];
  List<List<String>> tabelaPag;
  List<List<String>> memoriaRAM;
  List<List<String>> memoriaROM;

  List<String> titles = [
    '[MMU] Tabela de Páginas',
    'Memória RAM',
    'Disco Rígido (HD)'
  ];

  //funções

  @override
  void initState() {
    // atribuir a variaveis locais
    bitsEnderecamento = widget.args['bitsEnderecamento'];
    bitsOffset = widget.args['bitsOffset'];
    blocosMemoria = widget.args['blocosMemoria'];
    algoSel = widget.args['algoSel'];

    //numero de bits do endereçamento elevado a 2 para o tam. Tabela
    tamanhoTabela = pow(2, bitsEnderecamento);
    print('tamanho tabela ' + tamanhoTabela.toString());

    //numero de bits do offset elevado a 2 para o tam. das pos RAM
    tamanhoRAM = pow(2, bitsOffset);
    print('tamanho RAM ' + tamanhoRAM.toString());

    // criar tabela de paginas e preencher com 0
    // ignore: deprecated_member_use
    tabelaPag = new List<List<String>>();
    //colunas
    for (var i = 0; i < tamanhoTabela; i++) {
      // criar lista que ira ser adicionada na lista de tabelas (criar linha)
      List<String> list = [];
      // preencher com 0s
      for (var j = 0; j < 4; j++) {
        //linhas
        if (j == 0)
          list.add('x');
        else
          list.add(0.toString());
      }

      tabelaPag.add(list);
    }

    //preencher memoriaRAM
    // criar tabela de paginas e preencher com 0
    // ignore: deprecated_member_use
    memoriaRAM = new List<List<String>>();
    //colunas
    for (var i = 0; i < blocosMemoria; i++) {
      // criar lista que ira ser adicionada na lista de tabelas (criar linha)
      List<String> list = [];
      // preencher com 0s
      for (var j = 0; j < tamanhoRAM; j++) {
        //linhas
        list.add(0.toString());
      }

      memoriaRAM.add(list);
    }

    //preencher memoriaROM
    // criar tabela de paginas e preencher com 0
    // ignore: deprecated_member_use
    memoriaROM = new List<List<String>>();
    //colunas
    for (var i = 0; i < tamanhoTabela; i++) {
      // criar lista que ira ser adicionada na lista de tabelas (criar linha)
      List<String> list = [];
      // preencher com 0s
      for (var j = 0; j < tamanhoRAM; j++) {
        //linhas
        list.add(0.toString());
      }

      memoriaROM.add(list);
    }

    super.initState();
  }

  int binarioParaDecimal(int n) {
    int num = n;
    int decValue = 0;

    // Initializing base value to 1, i.e 2^0
    int base = 1;

    int temp = num;
    while (temp > 0) {
      int lastDigit = temp % 10;
      temp = temp ~/ 10;

      decValue += lastDigit * base;

      base = base * 2;
    }
    return decValue;
  }

  int decimalParaBinario(int dec) {
    var bin = '';
    while (dec > 0) {
      bin = (dec % 2 == 0 ? '0' : '1') + bin;
      dec ~/= 2;
    }
    return int.parse(bin);
  }

  bool validarInput() {
    RegExp regex = new RegExp(r'^[0-1]+$');
    if (regex.hasMatch(offsetBin.text) && regex.hasMatch(enderecoBin.text))
      return true;
    else
      return false;
  }

  atualizarListaBlocos(int bloco) {
    using.remove(bloco);
    using.add(bloco);
  }

  fifoAlgo() {
    int bloco;
    //se os blocos estiverem vazios
    if (blocosUsando == 0) {
      print('blocos vazios');
      bloco = blocosUsando;
      blocosUsando++;
      using.add(bloco);
      return bloco;
    } else {
      //se existir pelo menos um blocos não vazio

      if (blocosUsando >= blocosMemoria) {
        print('blocos cheios');
        //todos os blocos estão sendo utilizados
        //SWAPING AQUI

        int blocoMaisVelho =
            using.removeAt(0); //remove o bloco mais velho (FIFO)
        blocosUsando--; //diminui no count de blocos usados
        int tempPos = 0;

        print('bloco mais velho: ' + blocoMaisVelho.toString());

        while (!tabelaPag[tempPos][0].contains(blocoMaisVelho.toString())) {
          //procurar qual a posição da tabela está no bloco a ser retirado
          tempPos++;
        }
        print('pos achada = ' + tempPos.toString());

        // REALIZAR SWAPING
        print('REALIZANDO SWAPPING');

        print('memoria RAM $blocoMaisVelho: ' +
            memoriaRAM[blocoMaisVelho].toString());

        //atualizar a linha onde o bloco da memoria RAM é copiado para a linha da ROM

        for (int i = 0; i < tamanhoRAM; i++) {
          setState(() {
            memoriaROM[tempPos][i] = memoriaRAM[blocoMaisVelho][i];
          });
        }

        print('memoria ROM $tempPos: ' + memoriaROM[tempPos].toString());

        setState(() {
          // ATUALIZAR TABELA
          tabelaPag[tempPos][0] = 'x'; //[0] pagina
          tabelaPag[tempPos][1] = '0'; //[1] ativa ou não
          tabelaPag[tempPos][2] = '0'; //[2] time in
          tabelaPag[tempPos][3] = '0'; //[3] last acess time
        });

        // CLEAR DO BLOCO DA MEMORIA RAM
        List<String> list = [];
        // preencher com 0s
        for (var j = 0; j < tamanhoRAM; j++) {
          //linhas
          //list.add(0.toString());

          setState(() {
            memoriaRAM[blocoMaisVelho][j] = 0.toString();
          });
        }

        //SWAPPING REALIZADO
        print('SWAPPING REALIZADO');

        bloco = blocoMaisVelho;
        blocosUsando++;
        using.add(bloco);
        return bloco;
      } else {
        print('há blocos vazios');
        //ainda há blocos não utilizados
        for (int i = 0; i < blocosMemoria; i++) {
          //verificar qual bloco está disponível
          if (!using.contains(i)) {
            print('bloco $i está disponível');
            bloco = i;
            blocosUsando++;
            using.add(bloco);
            return bloco;
          } else {
            print('bloco $i está sendo utilizado');
          }
        }
      }
    }
  }

  atualizarTabela(int pos) {
    int pagFifo;

    //FIRST IN FIRST OUT
    pagFifo = fifoAlgo();

    setState(() {
      tabelaPag[pos][0] = pagFifo.toString(); //[0] pagina
      tabelaPag[pos][1] = '1'; //[1] ativa ou não
      tabelaPag[pos][2] = (DateTime.now().toString()); //[2] time in
      tabelaPag[pos][2] = (DateTime.now().toString()); //[3] last time acess
    });
    return pagFifo;
  }

  atualizarRAM(bool isInMemory, {@required int pos, @required int offset}) {
    int pagFifo;

    //puxar bloco da memoria ROM para jogar a memoria RAM
    List<String> tempROM = memoriaROM[pos];
    print(isInMemory);

    if (isInMemory) {
      //se estiver na memoria
      pagFifo = int.parse(tabelaPag[pos][0]);
    } else {
      //se não estiver na memoria
      pagFifo = atualizarTabela(pos);
      print('memoria ROM passada: ' + tempROM.toString());
      for (int i = 0; i < bitsOffset; i++) {
        setState(() {
          memoriaRAM[pagFifo][i] = tempROM[i];
        });
      }
    }
    setState(() {
      memoriaRAM[pagFifo][offset] = '1';
      tabelaPag[pos][3] = DateTime.now().toString();
      if (algoSel == 2) atualizarListaBlocos(pagFifo);
    });
  }

  addNovoEndVirtual(String end) {
    //conversões
    print('\n\nentrada em decimal = ' +
        binarioParaDecimal(int.parse(end)).toString() +
        '\nentrada em binario: ' +
        end);
    int pagV =
        binarioParaDecimal(int.parse(end.substring(0, bitsEnderecamento)));
    int offset = binarioParaDecimal(
        int.parse(end.substring(bitsEnderecamento, end.length)));
    print('pag virt = ' + pagV.toString());
    print('offset = ' + offset.toString());

    //verificações
    if (int.parse(tabelaPag[pagV][1]) == 0) {
      //posição não estiver na memória

      atualizarRAM(false, pos: pagV, offset: offset);
    } else if (int.parse(tabelaPag[pagV][1]) == 1) {
      //posição estiver na memória
      atualizarRAM(true, pos: pagV, offset: offset);
    }
  }

  setSelectedRadio(int val) {
    setState(() {
      selectedRadio = val;
    });
  }

  resetInput() {
    setState(() {
      enderecoBin.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          SizedBox(
            width: 18,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 12),
                  width: width * 0.2,
                  height: 50,
                  child: ElevatedButton(
                      style: ButtonStyle(),
                      onPressed: () {
                        setState(() {
                          page = 0;
                        });
                      },
                      child: Text(
                        'Visualizar tabela de páginas',
                        style: GoogleFonts.openSans(),
                      )),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 12),
                  width: width * 0.2,
                  height: 50,
                  child: ElevatedButton(
                      style: ButtonStyle(),
                      onPressed: () {
                        setState(() {
                          page = 1;
                        });
                      },
                      child: Text(
                        'Visualizar memória RAM',
                        style: GoogleFonts.openSans(),
                      )),
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 12),
                  width: width * 0.2,
                  height: 50,
                  child: ElevatedButton(
                      style: ButtonStyle(),
                      onPressed: () {
                        setState(() {
                          page = 2;
                        });
                      },
                      child: Text(
                        'Visualizar HD',
                        style: GoogleFonts.openSans(),
                      )),
                ),
                ButtonBar(
                  alignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Row(
                      children: [
                        Radio(
                          value: 1,
                          groupValue: selectedRadio,
                          activeColor: Colors.blue,
                          onChanged: (val) {
                            print("binario");
                            setSelectedRadio(val);
                            resetInput();
                          },
                        ),
                        Text('Binário', style: GoogleFonts.openSans())
                      ],
                    ),
                    Row(
                      children: [
                        Radio(
                          value: 2,
                          groupValue: selectedRadio,
                          activeColor: Colors.blue,
                          onChanged: (val) {
                            print("decimal");
                            setSelectedRadio(val);
                            resetInput();
                          },
                        ),
                        Text('Decimal', style: GoogleFonts.openSans())
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: 18,
                ),
                Text("Pilha de retirada",
                    style: GoogleFonts.openSans(fontSize: 20)),
                Container(
                    margin: EdgeInsets.symmetric(vertical: 12),
                    color: Colors.grey[200],
                    width: width * 0.2,
                    height: 150,
                    child: ListView.builder(
                        controller: _scrollControllerFila,
                        itemCount: using.length,
                        itemBuilder: (context, index) {
                          return Container(
                            width: width * 0.23,
                            decoration: BoxDecoration(
                                border: Border.all(color: Colors.black)),
                            height: 40,
                            child: Center(child: Text(using[index].toString())),
                          );
                        })),
                SizedBox(
                  height: 12,
                ),
                Container(
                  margin: EdgeInsets.symmetric(vertical: 12),
                  width: width * 0.2,
                  height: 50,
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(primary: Colors.red),
                      onPressed: () {
                        Navigator.pushReplacementNamed(
                          context,
                          '/firstscreen',
                        );
                      },
                      child: Text('Redefinir MMU',
                          style: GoogleFonts.openSans(
                              fontWeight: FontWeight.w400))),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: VerticalDivider(
              color: Colors.black,
              width: 25,
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 60,
                  width: width * 0.6,
                  child: Row(
                    children: [
                      Text('Inserir novo endereço virtual de memória: ',
                          style: GoogleFonts.openSans(
                            fontWeight: FontWeight.w600,
                          )),
                      SizedBox(
                        width: 24,
                      ),
                      Expanded(
                          child: TextField(
                        controller: enderecoBin,
                        decoration: InputDecoration(helperText: 'Página'),
                        maxLength: bitsEnderecamento,
                      )),
                      SizedBox(
                        width: 24,
                      ),
                      Expanded(
                          child: TextField(
                        controller: offsetBin,
                        decoration: InputDecoration(helperText: 'OffSet'),
                        maxLength: bitsOffset,
                      )),
                      SizedBox(
                        width: 24,
                      ),
                      Container(
                        child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Colors.grey[600]),
                            onPressed: () {
                              if (offsetBin.text.isNotEmpty &&
                                  enderecoBin.text.isNotEmpty &&
                                  validarInput()) {
                                if (selectedRadio == 1) {
                                  //binario
                                  addNovoEndVirtual(
                                      enderecoBin.text + offsetBin.text);

                                  enderecoBin.clear();
                                  offsetBin.clear();
                                } else if (selectedRadio == 2) {
                                  //decimal
                                  addNovoEndVirtual(decimalParaBinario(
                                          int.parse(enderecoBin.text))
                                      .toString());
                                }
                              }
                            },
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 5),
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                              ),
                            )),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
                Text(titles[page],
                    style: GoogleFonts.openSans(
                        fontSize: 32, fontWeight: FontWeight.w700)),
                SizedBox(
                  height: 12,
                ),
                page == 0
                    ? TabelaPagTile(width: width, tabelaPag: tabelaPag)
                    : page == 1
                        ? MemoriaRAMTile(
                            width: width,
                            height: height,
                            memoriaRAM: memoriaRAM,
                            tabela: tabelaPag,
                          )
                        : MemoriaROMTile(
                            width: width,
                            height: height,
                            memoriaROM: memoriaROM)
              ],
            ),
          )
        ],
      ),
    );
  }
}

class MemoriaROMTile extends StatefulWidget {
  const MemoriaROMTile({
    Key key,
    @required this.width,
    @required this.height,
    @required this.memoriaROM,
  }) : super(key: key);

  final double width;
  final double height;
  final List<List<String>> memoriaROM;

  @override
  _MemoriaROMTileState createState() => _MemoriaROMTileState();
}

class _MemoriaROMTileState extends State<MemoriaROMTile> {
  ScrollController _scrollControllerScrollbar = new ScrollController();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: widget.width * 0.9,
        height: widget.height * 0.8,
        margin: EdgeInsets.symmetric(vertical: 20),
        child: Scrollbar(
          isAlwaysShown: true,
          controller: _scrollControllerScrollbar,
          child: ListView.builder(
              controller: _scrollControllerScrollbar,
              scrollDirection: Axis.horizontal,
              itemCount: widget.memoriaROM.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 300,
                  height: 400,
                  child: Column(
                    children: [
                      Text(
                        'Página - ' + index.toString(),
                        style: GoogleFonts.openSans(
                            fontWeight: FontWeight.w600, fontSize: 20),
                      ),
                      Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 15),
                          decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(5)),
                          height: widget.height * 0.6,
                          width: 300,
                          child: Container(
                            width: 80,
                            height: 800,
                            child: ListView.builder(
                                itemCount: widget.memoriaROM[index].length,
                                padding: EdgeInsets.symmetric(vertical: 10),
                                itemBuilder: (context, index2) {
                                  String state =
                                      widget.memoriaROM[index][index2] == '0'
                                          ? 'Not Used'
                                          : 'Used';
                                  return Container(
                                    child: Column(
                                      children: [
                                        Text(
                                          'POS: ' +
                                              (index2).toString() +
                                              ' - ' +
                                              state,
                                          style: GoogleFonts.openSans(
                                              fontSize: 14,
                                              fontWeight:
                                                  widget.memoriaROM[index]
                                                              [index2] ==
                                                          '0'
                                                      ? FontWeight.w500
                                                      : FontWeight.w800),
                                        ),
                                        Divider()
                                      ],
                                    ),
                                  );
                                }),
                          )),
                    ],
                  ),
                );
              }),
        ),
      ),
    );
  }
}

class MemoriaRAMTile extends StatefulWidget {
  const MemoriaRAMTile({
    Key key,
    @required this.width,
    @required this.height,
    @required this.memoriaRAM,
    @required this.tabela,
  }) : super(key: key);

  final double width;
  final double height;
  final List<List<String>> memoriaRAM;
  final List<List<String>> tabela;

  @override
  _MemoriaRAMTileState createState() => _MemoriaRAMTileState();
}

class _MemoriaRAMTileState extends State<MemoriaRAMTile> {
  ScrollController _scrollControllerScrollbar = new ScrollController();

  String pertence(int index) {
    for (int i = 0; i < widget.tabela.length; i++) {
      if (widget.tabela[i][0] == index.toString()) {
        return i.toString();
      }
    }
    return 'Vazio';
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        width: widget.width * 0.9,
        height: widget.height * 0.8,
        margin: EdgeInsets.symmetric(vertical: 20),
        child: Scrollbar(
          isAlwaysShown: true,
          controller: _scrollControllerScrollbar,
          child: ListView.builder(
              controller: _scrollControllerScrollbar,
              scrollDirection: Axis.horizontal,
              itemCount: widget.memoriaRAM.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 300,
                  height: 400,
                  child: Column(
                    children: [
                      Text(
                        'Bloco - ' +
                            index.toString() +
                            ' (' +
                            pertence(index) +
                            ')',
                        style: GoogleFonts.openSans(
                            fontWeight: FontWeight.w600, fontSize: 20),
                      ),
                      Container(
                          margin: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 15),
                          decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(5)),
                          height: widget.height * 0.6,
                          width: 300,
                          child: Container(
                            width: 80,
                            height: 800,
                            child: ListView.builder(
                                itemCount: widget.memoriaRAM[index].length,
                                padding: EdgeInsets.symmetric(vertical: 10),
                                itemBuilder: (context, index2) {
                                  String state =
                                      widget.memoriaRAM[index][index2] == '0'
                                          ? 'Not Used'
                                          : 'Used';
                                  return Container(
                                    child: Column(
                                      children: [
                                        Text(
                                          'POS: ' +
                                              (index2).toString() +
                                              ' - ' +
                                              state,
                                          style: GoogleFonts.openSans(
                                              fontSize: 14,
                                              fontWeight:
                                                  widget.memoriaRAM[index]
                                                              [index2] ==
                                                          '0'
                                                      ? FontWeight.w500
                                                      : FontWeight.w800),
                                        ),
                                        Divider()
                                      ],
                                    ),
                                  );
                                }),
                          )),
                    ],
                  ),
                );
              }),
        ),
      ),
    );
  }
}

class TabelaPagTile extends StatefulWidget {
  const TabelaPagTile({
    Key key,
    @required this.width,
    @required this.tabelaPag,
  }) : super(key: key);

  final double width;
  final List<List<String>> tabelaPag;

  @override
  _TabelaPagTileState createState() => _TabelaPagTileState();
}

class _TabelaPagTileState extends State<TabelaPagTile> {
  ScrollController _scrollControllerScrollbar = new ScrollController();
  //date formatter
  final f = new DateFormat('hh:mm:ss');

  String dateFormat(String date) {
    if (date != '0')
      return f.format(DateTime.parse(date));
    else
      return '0';
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: widget.width * 0.04),
        child: Scrollbar(
          isAlwaysShown: true,
          controller: _scrollControllerScrollbar,
          child: ListView.builder(
              controller: _scrollControllerScrollbar,
              itemCount: widget.tabelaPag.length,
              itemBuilder: (context, index) {
                int state = int.parse(widget.tabelaPag[index][1]);
                return Container(
                    margin: EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                        color: state == 1 ? Colors.black45 : Colors.grey[300],
                        borderRadius: BorderRadius.circular(5)),
                    height: 80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text('POSIÇÃO',
                                style: GoogleFonts.openSans(
                                    color: state == 1
                                        ? Colors.white
                                        : Colors.black,
                                    fontWeight: FontWeight.w700)),
                            Text(
                              index.toString(),
                              style: GoogleFonts.openSans(
                                color: state == 1 ? Colors.white : Colors.black,
                              ),
                            )
                          ],
                        ),
                        VerticalDivider(
                          color: Colors.black,
                          width: 20,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'PÁGINA',
                              style: GoogleFonts.openSans(
                                  color:
                                      state == 1 ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.w700),
                            ),
                            Text(
                              widget.tabelaPag[index][0].toString(),
                              style: GoogleFonts.openSans(
                                color: state == 1 ? Colors.white : Colors.black,
                              ),
                            )
                          ],
                        ),
                        VerticalDivider(
                          color: Colors.black,
                          width: 20,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'ATIVA',
                              style: GoogleFonts.openSans(
                                  color:
                                      state == 1 ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.w700),
                            ),
                            Text(
                              widget.tabelaPag[index][1].toString(),
                              style: GoogleFonts.openSans(
                                color: state == 1 ? Colors.white : Colors.black,
                              ),
                            )
                          ],
                        ),
                        VerticalDivider(
                          color: Colors.black,
                          width: 20,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'TIME-IN',
                              style: GoogleFonts.openSans(
                                  color:
                                      state == 1 ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.w700),
                            ),
                            Text(
                              dateFormat(widget.tabelaPag[index][2]),
                              style: GoogleFonts.openSans(
                                color: state == 1 ? Colors.white : Colors.black,
                              ),
                            )
                          ],
                        ),
                        VerticalDivider(
                          color: Colors.black,
                          width: 5,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              'LAST ACESS TIME',
                              style: GoogleFonts.openSans(
                                  fontSize: 12,
                                  color:
                                      state == 1 ? Colors.white : Colors.black,
                                  fontWeight: FontWeight.w700),
                            ),
                            Text(
                              dateFormat(widget.tabelaPag[index][3]),
                              style: GoogleFonts.openSans(
                                color: state == 1 ? Colors.white : Colors.black,
                              ),
                            )
                          ],
                        )
                      ],
                    ));
              }),
        ),
      ),
    );
  }
}
