import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:flutter_blue_example/device.dart';
import 'package:flutter_blue_example/widgets.dart';

class FindDevicesScreen extends StatefulWidget {
  @override
  _FindDevicesScreenState createState() => _FindDevicesScreenState();
}

class _FindDevicesScreenState extends State<FindDevicesScreen> {
  String _filterName = '';
  double _rssiThreshold = -100.0;
  bool _nameFilterEnabled = false;
  bool _rssiFilterEnabled = false;
  bool _isHeaderExpanded = true;
  bool _isScanning = false;

  int _totalDevices = 0;
  int _filteredDevices = 0;

  int get _activeFiltersCount =>
      (_nameFilterEnabled ? 1 : 0) + (_rssiFilterEnabled ? 1 : 0);

  bool _matchesFilters(ScanResult result) {
    final nameMatches =
        !_nameFilterEnabled || result.device.name.contains(_filterName);
    final rssiMatches = !_rssiFilterEnabled || result.rssi > _rssiThreshold;
    return nameMatches && rssiMatches;
  }

  void _toggleScan() {
    setState(() {
      _isScanning = !_isScanning;
      if (_isScanning) {
        FlutterBlue.instance.startScan(timeout: Duration(seconds: 4));
      } else {
        FlutterBlue.instance.stopScan();
      }
    });
  }

  Future<void> _refreshAndRescan() async {
    setState(() {
      _totalDevices = 0;
      _filteredDevices = 0;
    });
    await FlutterBlue.instance.stopScan();
    await FlutterBlue.instance.startScan(timeout: Duration(seconds: 4));
    setState(() {
      _isScanning = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isScanning ? '正在扫描中' : 'Zepp Tool'),
        actions: [
          IconButton(
            icon: Icon(_isScanning ? Icons.pause : Icons.play_arrow),
            onPressed: _toggleScan,
          ),
        ],
      ),
      body: Column(
        children: [
          // Enhanced Header View for Filters
          Container(
            color: isDarkMode ? Colors.grey[900] : Colors.grey[200],
            padding:
                const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display Active Filters Count and Collapse Icon
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _activeFiltersCount > 0
                          ? 'Filtering Active ($_filteredDevices/$_totalDevices)'
                          : 'No Filter',
                      style: TextStyle(
                          color: theme.colorScheme.onBackground,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _isHeaderExpanded = !_isHeaderExpanded;
                        });
                      },
                      child: Icon(
                        _isHeaderExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                if (_isHeaderExpanded) ...[
                  SizedBox(height: 12.0),
                  // Name Filter with Toggle
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            labelText: 'Name',
                            labelStyle: TextStyle(
                                color: theme.colorScheme.onBackground),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                    color: theme.colorScheme.primary)),
                            filled: true,
                            fillColor: isDarkMode
                                ? Colors.grey[800]
                                : Colors.grey[100],
                          ),
                          style:
                              TextStyle(color: theme.colorScheme.onBackground),
                          onChanged: (value) {
                            setState(() {
                              _filterName = value;
                              _nameFilterEnabled = value.isNotEmpty;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 8),
                      Switch(
                        value: _nameFilterEnabled,
                        onChanged: (value) {
                          setState(() {
                            _nameFilterEnabled = value;
                            if (!value) _filterName = '';
                          });
                        },
                        activeColor: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                  SizedBox(height: 12.0),
                  // RSSI Filter Slider with Toggle
                  Row(
                    children: [
                      Text(
                        'RSSI',
                        style: TextStyle(
                            color: theme.colorScheme.onBackground,
                            fontSize: 14,
                            fontWeight: FontWeight.w500),
                      ),
                      Expanded(
                        child: Slider(
                          min: -100,
                          max: 0,
                          divisions: 20,
                          value: _rssiThreshold,
                          onChanged: (value) {
                            setState(() {
                              _rssiThreshold = value;
                              _rssiFilterEnabled = true;
                            });
                          },
                          activeColor: theme.colorScheme.primary,
                          inactiveColor: theme.disabledColor,
                        ),
                      ),
                      Switch(
                        value: _rssiFilterEnabled,
                        onChanged: (value) {
                          setState(() {
                            _rssiFilterEnabled = value;
                          });
                        },
                        activeColor: theme.colorScheme.primary,
                      ),
                    ],
                  ),
                  Text(
                    'RSSI Threshold: ${_rssiThreshold.toInt()} dB',
                    style: TextStyle(color: theme.colorScheme.onBackground),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshAndRescan,
              child: SingleChildScrollView(
                child: Column(
                  children: <Widget>[
                    StreamBuilder<List<BluetoothDevice>>(
                      stream: Stream.periodic(Duration(seconds: 2)).asyncMap(
                          (_) => FlutterBlue.instance.connectedDevices),
                      initialData: [],
                      builder: (c, snapshot) {
                        final connectedDevices = snapshot.data!
                          ..sort((a, b) => a.name.compareTo(b.name));
                        return Column(
                          children: connectedDevices
                              .map((d) => ListTile(
                                    title: Text(d.name,
                                        style: TextStyle(
                                            color: theme
                                                .colorScheme.onBackground)),
                                    subtitle: Text(d.id.toString(),
                                        style: TextStyle(
                                            color:
                                                theme.colorScheme.onSurface)),
                                    trailing:
                                        StreamBuilder<BluetoothDeviceState>(
                                      stream: d.state,
                                      initialData:
                                          BluetoothDeviceState.disconnected,
                                      builder: (c, snapshot) {
                                        if (snapshot.data ==
                                            BluetoothDeviceState.connected) {
                                          return ElevatedButton(
                                            child: Text('已连接'),
                                            onPressed: () =>
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            DeviceScreen(
                                                                device: d))),
                                          );
                                        }
                                        return Text('未连接',
                                            style: TextStyle(
                                                color: theme
                                                    .colorScheme.onSurface));
                                      },
                                    ),
                                  ))
                              .toList(),
                        );
                      },
                    ),
                    StreamBuilder<List<ScanResult>>(
                      stream: FlutterBlue.instance.scanResults,
                      initialData: [],
                      builder: (c, snapshot) {
                        final results = snapshot.data ?? [];
                        _totalDevices = results.length;
                        final filteredResults =
                            results.where(_matchesFilters).toList();

                        final connectedResults = filteredResults
                            .where((r) =>
                                r.device.state ==
                                BluetoothDeviceState.connected)
                            .toList();
                        final unconnectedResults = filteredResults
                            .where((r) =>
                                r.device.state !=
                                BluetoothDeviceState.connected)
                            .toList();

                        connectedResults.sort(
                            (a, b) => a.device.name.compareTo(b.device.name));
                        unconnectedResults
                            .sort((a, b) => b.rssi.compareTo(a.rssi));

                        _filteredDevices =
                            connectedResults.length + unconnectedResults.length;

                        return Column(
                          children: [
                            ...connectedResults.map((r) => ScanResultTile(
                                  result: r,
                                  onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    r.device.connect();
                                    return DeviceScreen(device: r.device);
                                  })),
                                )),
                            ...unconnectedResults.map((r) => ScanResultTile(
                                  result: r,
                                  onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(builder: (context) {
                                    r.device.connect();
                                    return DeviceScreen(device: r.device);
                                  })),
                                )),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: StreamBuilder<bool>(
        stream: FlutterBlue.instance.isScanning,
        initialData: false,
        builder: (c, snapshot) {
          if (snapshot.data!) {
            return FloatingActionButton(
              child: Icon(Icons.stop),
              onPressed: () => FlutterBlue.instance.stopScan(),
              backgroundColor: Colors.red,
            );
          } else {
            return FloatingActionButton(
              child: Icon(Icons.search),
              onPressed: () =>
                  FlutterBlue.instance.startScan(timeout: Duration(seconds: 4)),
              backgroundColor: theme.colorScheme.primary,
            );
          }
        },
      ),
    );
  }
}
