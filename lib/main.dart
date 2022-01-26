import 'dart:math';
import 'package:despesas_pessoais/Components/Chart.dart';
import 'package:despesas_pessoais/Components/Transaction_form.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Components/Transaction_list.dart';
import 'models/Transaction.dart';
import 'dart:io';

main() => runApp(ExpensesApp());

class ExpensesApp extends StatelessWidget {
  const ExpensesApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        accentColor: Colors.amber,
        fontFamily: 'Quicksand',
        textTheme: ThemeData.light().textTheme.copyWith(
            headline6: TextStyle(
              fontFamily: 'OpenSans',
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            button: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )),
        appBarTheme: AppBarTheme(
          textTheme: ThemeData.light().textTheme.copyWith(
                headline6: TextStyle(
                  fontFamily: 'OpenSans',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
        ),
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  _addTransaction(String title, double value, DateTime date) {
    final newTransaction = Transaction(
      id: Random().nextDouble().toString(),
      title: title,
      value: value,
      date: date,
    );
    setState(() {
      _transactions.add(newTransaction);
    });

    Navigator.of(context).pop();
  }

  final List<Transaction> _transactions = [];
  bool _showChart = false;

  List<Transaction> get _recentTransactions {
    return _transactions.where((tr) {
      return tr.date.isAfter(DateTime.now().subtract(Duration(days: 7)));
    }).toList();
  }

  _removeTransaction(String id) {
    setState(() {
      _transactions.removeWhere((tr) => tr.id == id);
    });
  }

  _openTransactionFormModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return TransactionForm(_addTransaction);
      },
    );
  }

  Widget _getIconButton(IconData icon, Function() fn) {
    return Platform.isIOS
      ? GestureDetector(onTap: fn, child: Icon(icon))
      : IconButton(icon: Icon(icon), onPressed: fn);
    }


  @override
  Widget build(BuildContext context) {

    final mediaQuery = MediaQuery.of(context);
    final iconList = Platform.isIOS ? CupertinoIcons.refresh : Icons.list;
    final chartIcon = Platform.isIOS ? CupertinoIcons.refresh : Icons.bar_chart;
    bool isLandscape = mediaQuery.orientation == Orientation.landscape;

    final actions = [
      if(isLandscape)
        _getIconButton(
          _showChart ? iconList : chartIcon,
            (){
              setState(() {
                _showChart = !_showChart;
              });
            }
        ),
      _getIconButton(
          Platform.isIOS ? CupertinoIcons.add : Icons.add,
          () => _openTransactionFormModal(context),
      ),
    ];

    final appBar =
        AppBar(
            title: Text("Despesas Pessoais"),
            actions: actions
    );

    final availableHeight = mediaQuery.size.height -
        appBar.preferredSize.height -
        mediaQuery.padding.top;

    final bodyPage = SafeArea(
        child: SingleChildScrollView(
          child:
          Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // if(isLandscape)
                // Row(
                //   mainAxisAlignment: MainAxisAlignment.center,
                //   children: [
                //     Text('Exibir gráfico'),
                //     Switch.adaptive(
                //       activeColor: Theme.of(context).accentColor,
                //       value: _showChart,
                //       onChanged: (value) {
                //         setState(() {
                //           _showChart = value;
                //         });
                //       },
                //     ),
                //   ],
                // ),
                if(_showChart || !isLandscape)
                  Container(
                    height: availableHeight * (isLandscape ? 0.8 : 0.3),
                    child: Chart(_recentTransactions),
                  ),
                if(!_showChart || isLandscape)
                  Container(
                    height: availableHeight * (isLandscape ? 1 : 0.7),
                    child: TransactionList(
                      transactions: _transactions,
                      onRemove: _removeTransaction,
                    ),
                  ),
              ]
          ),
        )
    );



    return Platform.isIOS
      ? CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text('Despesas Pessoais'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: actions,
            ),
        ),
        child: bodyPage,
      ):
      Scaffold(
        appBar: appBar,
        body: bodyPage,
        floatingActionButton: Platform.isIOS
          ?Container()
          :FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () => _openTransactionFormModal(context),
          ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      );
    }
}
