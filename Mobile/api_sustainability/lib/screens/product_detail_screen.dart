import 'package:flutter/material.dart';

import 'package:charts_flutter/flutter.dart' as charts;
import 'package:provider/provider.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';
import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import '../providers/products.dart';
import '../providers/product.dart';

import 'package:intl/intl.dart';
import '../providers/auth.dart';

import 'package:flutter/cupertino.dart';
import 'package:api_sustainability/data/dummy.dart';
import 'package:api_sustainability/data/my_colors.dart';
import 'package:api_sustainability/models/shop_category.dart';
import 'package:api_sustainability/widgets/my_text.dart';

import 'package:api_sustainability/widgets/badge.dart';
import 'package:api_sustainability/widgets/my_text.dart';

math.Random random = new math.Random();
final double _initCarbonUsage = 100, _initLifeTimeValue = 2;

class ProductDetailScreen extends StatefulWidget {
  // final String title;
  static const routeName = '/product-detail';

  @override
  _ProductDetailScreenState createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  static var chartDisplay;

  void initState() {
    setState(() {
      var data = [
        addcharts("val 1", 10),
        addcharts("val 2", 50),
        addcharts("val 3", 40),
        addcharts("val 4", 30),
        addcharts("val 5", 20),
      ];
      var series = [
        charts.Series(
          domainFn: (addcharts addcharts, _) => addcharts.label,
          measureFn: (addcharts addcharts, _) => addcharts.value,
          id: 'addcharts',
          data: data,
        )
      ];

      chartDisplay = charts.BarChart(
        series,
        animate: false,
      );
    });
  }

  double _lifeTimeValue = _initLifeTimeValue;
  double _carbonUsage = _initCarbonUsage;
  double _estimatedPerYear = 1;
  final marginLeftOnly = EdgeInsets.only(left: 20, right: 20);
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<double> _generateRandomData(int count) {
    List<double> result = <double>[];
    for (int i = 0; i < count; i++) {
      result.add(random.nextDouble() * 100);
    }
    return result;
  }

  List<double> _generateCarbonData(int count) {
    List<double> result = <double>[];
    for (int i = 0; i < count; i++) {
      result.add(_carbonUsage * (i / _lifeTimeValue).round());
    }
    return result;
  }

  var isProductLoaded = false;
  @override
  Widget build(BuildContext context) {
    _estimatedPerYear = 12 / _lifeTimeValue;
    // final product = Provider.of<Product>(context, listen: false);
    final authData = Provider.of<Auth>(context, listen: false);
    final productsData = Provider.of<Products>(context);
    var data = _generateCarbonData(10);
    final flSpotData =
        List.generate(101, (i) => _carbonUsage * (i / _lifeTimeValue).round())
            .map((x) => FlSpot(x / 3, (x)))
            .toList();
    final productId =
        ModalRoute.of(context).settings.arguments as String; // is the id!
    final loadedProduct = Provider.of<Products>(
      context,
      listen: false,
    ).findById(productId);

    if (!isProductLoaded) {
      setState(() {
        isProductLoaded = true;
        _carbonUsage = loadedProduct.carbon;
        _lifeTimeValue = loadedProduct.lifespam;
      });
    }

    return Scaffold(
      // appBar: AppBar(
      //   title: Text(loadedProduct.title),
      // ),
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            // leading: IconButton(
            //   icon: Icon(
            //     Icons.menu,
            //     size: 90,
            //   ),
            //   onPressed: () => {},
            // ),
            backgroundColor: Colors.white,
            iconTheme: IconThemeData(
              // color: Theme.of(context).primaryColor,
              opacity: 1,
              color: Colors.lightGreen,
              size: 100,
            ),
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: loadedProduct.id,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(19),
                  child: Container(
                    color: Colors.black,
                    child: Opacity(
                      opacity: .7,
                      child: Image.network(
                        loadedProduct.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              SizedBox(height: 10),
              Text(
                '${loadedProduct.title}',
                style: MyText.display3(context),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10),
              Text(
                '\$${loadedProduct.price}',
                style: MyText.display1(context),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                margin: marginLeftOnly,
                child: FlatButton(
                  child: RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.body1,
                      children: [
                        TextSpan(
                            text: loadedProduct.isFavorite
                                ? "I am using this "
                                : 'Start using this ',
                            style: MyText.headline(context).copyWith(
                                color: Theme.of(context).accentColor)),
                        WidgetSpan(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 2.0),
                            child: Icon(
                              loadedProduct.isFavorite
                                  ? Icons.assignment_turned_in
                                  : Icons.assignment_turned_in_outlined,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  onPressed: () {
                    loadedProduct.toggleFavoriteStatus(
                        authData.token, authData.userId);
                    setState(() {});
                  },
                  textColor: Theme.of(context).primaryColor,
                ),
              ),
              VerticalSpace(
                height: 40,
              ),
              Padding(
                padding: marginLeftOnly,
                child: Text(
                    "Carbon cost per unit: ${_carbonUsage.toStringAsFixed(3)}",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    )),
              ),
              Slider(
                value: _carbonUsage,
                min: 0.001 > _carbonUsage ? _carbonUsage * 0.1 : 0.01,
                max: _initCarbonUsage * 10 < _carbonUsage
                    ? _carbonUsage * 2
                    : _initCarbonUsage * 10,
                label: _carbonUsage.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    _carbonUsage = value;
                  });
                },
              ),
              VerticalSpace(),
              Padding(
                padding: marginLeftOnly,
                child: Text(
                    "Lifespan: ${_lifeTimeValue.toStringAsFixed(3)} (months)",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    )),
              ),
              Slider(
                value: _lifeTimeValue,
                min: 1 > _lifeTimeValue ? 0.1 * _lifeTimeValue : 1,
                max: 48 <= _lifeTimeValue ? _lifeTimeValue * 2 : 48,
                divisions: 48 * 2,
                label: _lifeTimeValue.round().toString(),
                onChanged: (double value) {
                  setState(() {
                    _lifeTimeValue = value;
                  });
                },
              ),
              VerticalSpace(),
              Padding(
                padding: marginLeftOnly,
                child: Text(
                    "Estimated purchase per year: ${_estimatedPerYear.toStringAsFixed(3)} times",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    )),
              ),
              Padding(
                padding: marginLeftOnly,
                child: Container(
                  width: 300.0,
                  height: 100.0,
                  child: new Sparkline(
                    data: data,
                    lineColor: Colors.lightGreen[500],
                    fillMode: FillMode.below,
                    fillColor: Colors.lightGreen[200],
                    pointsMode: PointsMode.all,
                    pointSize: 5.0,
                    pointColor: Colors.amber,
                  ),
                ),
              ),
              VerticalSpace(),
              Padding(
                padding: marginLeftOnly,
                child: Text(
                  "Alternatives",
                  style: MyText.display1(context),
                ),
              ),
              Padding(
                padding: marginLeftOnly,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Row(
                          children: productsData
                              .getAlternatives(loadedProduct)
                              .map((item) {
                        return Container(
                          // height: 100,
                          margin: const EdgeInsets.only(
                              left: 20, right: 20, top: 20, bottom: 20),
                          child: GestureDetector(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                    width: 120,
                                    height: 100,
                                    decoration: BoxDecoration(
                                      color: const Color(0xff7c94b6),

                                      // color: Colors.black,
                                      image: DecorationImage(
                                          colorFilter: new ColorFilter.mode(
                                              Colors.white.withOpacity(.84),
                                              BlendMode.dstATop),
                                          image: NetworkImage(item.imageUrl),
                                          fit: BoxFit.cover),
                                    ),
                                    child: Center(
                                      child: Text(
                                        item.title,
                                        style: MyText.body2(context),
                                      ),
                                    )),
                              ),
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                  ProductDetailScreen.routeName,
                                  arguments: item.id,
                                );
                              }),
                        );
                      }).toList()),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 400,
                child: chartDisplay,
              )
            ]),
          ),
        ],
      ),
    );
  }
}