import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_connectivity_test/src/service/latency_service.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:mrx_charts/mrx_charts.dart';

class ChartDialog extends StatefulWidget {
  final int index;

  const ChartDialog({super.key, required this.index});

  static void show(BuildContext context, int index) {
    showDialog(
      barrierDismissible: true,
      context: context,
      builder: (context) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          child: ChartDialog(index: index),
        ),
      ),
    );
  }

  @override
  State<ChartDialog> createState() => _ChartDialogState();
}

class _ChartDialogState extends State<ChartDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController animController;

  final double maxElements = 20.0;

  List<ChartLineDataItem> chartData = [];

  Timer? chartUpdateTimer;

  double maxGraphHeight = 0;
  double minGraphHeight = 0;

  bool loading = true;

  @override
  void initState() {
    super.initState();

    animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2500));

    chartData = [];

    chartUpdateTimer =
        Timer.periodic(const Duration(milliseconds: 1000), (Timer t) async {
      chartData = LatencyInfos().getChartData(widget.index).sublist(
          LatencyInfos().getChartData(widget.index).length > maxElements.toInt()
              ? LatencyInfos().getChartData(widget.index).length -
                  maxElements.toInt()
              : 0);

      if (chartData.isNotEmpty) {

        ChartLineDataItem itemMax =
            chartData.reduce((a, b) => a.value > b.value ? a : b);
        maxGraphHeight = itemMax.value < 0 ? itemMax.value.abs() : itemMax.value;
        //print('max $maxGraphHeight');

        ChartLineDataItem itemMin =
            chartData.reduce((a, b) => a.value < b.value ? a : b);
        minGraphHeight = itemMin.value < 0 ? itemMin.value.abs() : itemMin.value;
        //print('min $minGraphHeight');

        chartData.asMap().forEach((index, item) {
          updateData(
            index,
            ChartLineDataItem(
              value: item.value < 0 ? item.value.abs() : item.value,
              x: index.toDouble() + 1,
            ),
          );
        });

      } else {
        loading = false;
        setState(() {  });
      }
    });
  }

  void addNewData(ChartLineDataItem newItem) {
    setState(() {
      chartData.add(newItem);
    });
  }

  void updateData(int index, ChartLineDataItem updatedItem) {
    setState(() {
      if (index >= 0 && index < chartData.length) {
        chartData[index] = updatedItem;
      }
    });
  }

  void removeData(int index) {
    setState(() {
      if (index >= 0 && index < chartData.length) {
        chartData.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            getTitleForIndex(widget.index),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: chartData.isNotEmpty
                ? Chart(
                    duration: const Duration(milliseconds: 40),
                    layers: [
                      ChartAxisLayer(
                        settings: ChartAxisSettings(
                          x: ChartAxisSettingsAxis(
                              frequency: 1.0,
                              max: chartData.length.toDouble(),
                              min: 0.0,
                              textStyle: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                              )),
                          y: ChartAxisSettingsAxis(
                              frequency: maxGraphHeight < 10 ? 1 : 10.0,
                              max: maxGraphHeight == 0 ? 10 : maxGraphHeight * 1.5,
                              min: minGraphHeight * 0.5,
                              textStyle: const TextStyle(
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                              )),
                        ),
                        labelX: (double labelX) {
                          return labelX % 5 == 0
                              ? labelX.toInt().toString()
                              : '';
                        },
                        labelY: (double labelY) {
                          return labelY.toInt().toString();
                        },
                      ),
                      ChartLineLayer(
                        items: chartData,
                        settings: const ChartLineSettings(
                          color: Colors.white60,
                          thickness: 3.0,
                        ),
                      ),
                    ],
                  )
                : loading ? Center(
                    child: SpinKitSpinningLines(
                    color: Colors.white,
                    itemCount: 5,
                    size: 200.0,
                    controller: animController,
                  )) : Center(
                    child: Text('NO DATA', style: TextStyle(fontSize: 24),)),
          ),
        ],
      ),
    );
  }

  getTitleForIndex(index) {
    switch (index) {
      case 1:
        return "SS-RSRP History (dB)";
      case 2:
        return "Latency History (ms)";
      case 3:
        return "Jitter History (ms)";
      default:
    }
  }

  @override
  void dispose() {
    chartUpdateTimer?.cancel();
    animController.dispose();
    super.dispose();
  }
}
