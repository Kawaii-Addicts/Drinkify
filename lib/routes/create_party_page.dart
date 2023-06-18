import 'package:drinkify/widgets/createpartypage/invite_friends.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart' hide Location;
import 'package:location/location.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../utils/theming.dart';
import '../widgets/custom_floating_button.dart';
import '../routes/create_party_routes/description_page.dart';
import '../widgets/createpartypage/party_status.dart';
import '../widgets/createpartypage/datetime_fields.dart';
import '../models/user.dart';

class CreatePartyRoute extends StatefulWidget {
  const CreatePartyRoute({super.key});

  @override
  State<CreatePartyRoute> createState() => _CreatePartyRouteState();
}

class _CreatePartyRouteState extends State<CreatePartyRoute> {
  //List of elements needed to send in the http request
  LatLng? selPoint;
  late final TextEditingController titleCtrl;
  DateTime? startTime;
  DateTime? endTime;
  late final TextEditingController descriptionCtrl;
  late int partyStatus;
  late List<User> invitedUsers;

  String? selLocation;
  late final MapController mapCtrl;
  late bool isFullyScrolled;
  int? selectedFieldIndex;

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  ///[selectLocation] must be true if you want to put marker on user's location after collecting coordinates
  void _getUserLocation({bool selectLocation = false}) async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    final Location location = Location();

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    final LocationData posData = await location.getLocation();

    var loc = <Placemark>[];
    try {
      loc = await placemarkFromCoordinates(
        posData.latitude!,
        posData.longitude!,
      );
    } catch (_) {
      return;
    }

    final cityFields = <String>[
      loc[0].locality!,
      loc[0].administrativeArea!,
      loc[0].subAdministrativeArea!,
      loc[0].subLocality!,
    ];
    String locArea = "";

    for (final i in cityFields) {
      if (i != "") {
        locArea = i;
        break;
      }
    }

    final bool addComma = locArea != "";

    if (mounted) {
      mapCtrl.move(
        LatLng(posData.latitude!, posData.longitude!),
        14,
      );
    }
    if (selectLocation) {
      setState(() {
        selPoint = LatLng(
          posData.latitude!,
          posData.longitude!,
        );
        selLocation =
            "${loc[0].country}${addComma ? ", $locArea" : ""}, ${loc[0].street}";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _getUserLocation(selectLocation: false);
    isFullyScrolled = false;
    mapCtrl = MapController();
    titleCtrl = TextEditingController();
    descriptionCtrl = TextEditingController();
    partyStatus = 1;
    invitedUsers = [];
  }

  @override
  void dispose() {
    super.dispose();
    mapCtrl.dispose();
    titleCtrl.dispose();
    descriptionCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theming.bgColor,
      floatingActionButton: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOutBack,
        scale: isFullyScrolled ? 1 : 0,
        child: CustomFloatingButton(
          caption: AppLocalizations.of(context)!.createAParty,
          onTap: () {
            //TODO: create party
          },
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapCtrl,
            options: MapOptions(
              interactiveFlags: InteractiveFlag.all -
                  InteractiveFlag.doubleTapZoom -
                  InteractiveFlag.rotate,
              onTap: (_, pos) async {
                var loc = <Placemark>[];
                try {
                  loc = await placemarkFromCoordinates(
                    pos.latitude,
                    pos.longitude,
                  );
                } catch (_) {
                  return;
                }

                final cityFields = <String>[
                  loc[0].locality!,
                  loc[0].administrativeArea!,
                  loc[0].subAdministrativeArea!,
                  loc[0].subLocality!,
                ];
                String locArea = "";

                for (final i in cityFields) {
                  if (i != "") {
                    locArea = i;
                    break;
                  }
                }

                bool addComma = locArea != "";

                setState(() {
                  selPoint = pos;
                  selLocation =
                      "${loc[0].country}${addComma ? ", $locArea" : ""}, ${loc[0].street}";
                });
              },
            ),
            nonRotatedChildren: [
              MarkerLayer(
                markers: [
                  Marker(
                    point: selPoint ?? LatLng(0, 0),
                    builder: (_) {
                      return Visibility(
                        visible: selPoint == null ? false : true,
                        child: const Icon(
                          Icons.location_pin,
                          color: Theming.primaryColor,
                          size: 36,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
            children: [
              TileLayer(
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: "app.drinkify",
              ),
            ],
          ),

          // Return button, my location button
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).viewPadding.top + 10,
              left: 30,
              right: 30,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(
                    height: 40,
                    width: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theming.bgColor.withOpacity(0.5),
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Theming.whiteTone,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _getUserLocation(selectLocation: true),
                  child: Container(
                    height: 40,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Theming.bgColor.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.my_location_rounded,
                          color: Theming.whiteTone,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          AppLocalizations.of(context)!.myLocation,
                          style: const TextStyle(
                            color: Theming.whiteTone,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          NotificationListener<DraggableScrollableNotification>(
            onNotification: (notif) {
              final double dragRatio = (notif.extent - notif.minExtent) /
                  (notif.maxExtent - notif.minExtent);

              if (dragRatio >= 0.9 && isFullyScrolled != true) {
                setState(() => isFullyScrolled = true);
              }
              if (dragRatio < 0.9 && isFullyScrolled != false) {
                setState(() => isFullyScrolled = false);
              }

              return true;
            },
            child: DraggableScrollableSheet(
              maxChildSize: 1,
              initialChildSize: 0.16,
              minChildSize: 0.16,
              snap: true,
              builder: (ctx, scrollCtrl) {
                return SingleChildScrollView(
                  controller: scrollCtrl,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Theming.whiteTone,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: 5,
                          width: MediaQuery.of(ctx).size.width / 5,
                          margin: const EdgeInsets.only(top: 5),
                          decoration: BoxDecoration(
                            color: Theming.bgColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(ctx).size.height * 0.12 - 10,
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 30,
                                ),
                                child: Text(
                                  AppLocalizations.of(context)!
                                      .location
                                      .toUpperCase(),
                                  style: TextStyle(
                                    color: Colors.black.withOpacity(0.2),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              Stack(
                                children: [
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 30,
                                          ),
                                          child: Text(
                                            selLocation ??
                                                AppLocalizations.of(context)!
                                                    .unknown,
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      _locationShadow(1),
                                      _locationShadow(-1),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(width: double.infinity),
                            ],
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 0.88,
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            color: Theming.bgColor,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(30),
                              topRight: Radius.circular(30),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 30,
                              right: 30,
                              top: 30,
                            ),
                            child: Column(
                              children: [
                                _formField(
                                  0,
                                  caption: AppLocalizations.of(context)!.title,
                                  placeholder: AppLocalizations.of(context)!
                                      .addPartyTitle,
                                  prefixIcon: Icons.label_important_outline,
                                  borderRadius: BorderRadius.circular(15),
                                  ctrl: titleCtrl,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    DateTimeField(
                                      isStart: true,
                                      onFinish: (start) {
                                        startTime = start;
                                      },
                                    ),
                                    Text(
                                      "-",
                                      style: TextStyle(
                                        fontSize: 42,
                                        fontWeight: FontWeight.bold,
                                        color:
                                            Theming.whiteTone.withOpacity(0.25),
                                      ),
                                    ),
                                    DateTimeField(
                                      isStart: false,
                                      onFinish: (end) {
                                        endTime = end;
                                      },
                                    ),
                                  ],
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (ctx, _, __) {
                                        return DescriptionPage(
                                          controller: descriptionCtrl,
                                        );
                                      },
                                    ),
                                  ),
                                  child: _formField(
                                    3,
                                    caption: AppLocalizations.of(context)!
                                        .description,
                                    placeholder: AppLocalizations.of(context)!
                                        .addPartyDescription,
                                    prefixIcon: Icons.description_outlined,
                                    ctrl: descriptionCtrl,
                                    enabled: false,
                                  ),
                                ),
                                PartyStatus(
                                  onSelect: (statusNumber) =>
                                      partyStatus = statusNumber,
                                ),
                                InviteFriends(
                                  onFinish: (friends) {
                                    invitedUsers = friends;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _formField(
    int index, {
    required String caption,
    required String placeholder,
    required IconData prefixIcon,
    required TextEditingController ctrl,
    bool manyInRow = false,
    bool enabled = true,
    BorderRadius borderRadius = const BorderRadius.only(
      topLeft: Radius.circular(15),
      topRight: Radius.circular(15),
      bottomLeft: Radius.circular(15),
      bottomRight: Radius.circular(15),
    ),
  }) {
    bool isSelected = index == selectedFieldIndex;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 15 / 2),
          child: Text(
            caption.toUpperCase(),
            style: TextStyle(
              color: isSelected
                  ? Theming.primaryColor
                  : Theming.whiteTone.withOpacity(0.3),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        AnimatedContainer(
          height: 50,
          width: manyInRow
              ? MediaQuery.of(context).size.width / 2 - 30 - 10
              : double.infinity,
          duration: const Duration(milliseconds: 300),
          curve: Curves.linearToEaseOut,
          padding: const EdgeInsets.only(right: 7.5),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Theming.whiteTone.withOpacity(0.1),
            borderRadius: borderRadius,
            border: Border.all(
              width: 1.5,
              color: isSelected || ctrl.text.isNotEmpty
                  ? Theming.primaryColor
                  : Theming.whiteTone.withOpacity(0.2),
            ),
          ),
          child: TextField(
            enabled: enabled,
            cursorColor: Theming.primaryColor,
            maxLines: 1,
            onTap: () {
              setState(() => selectedFieldIndex = index);
            },
            decoration: InputDecoration(
              hintText:
                  !enabled && ctrl.text.isNotEmpty ? ctrl.text : placeholder,
              hintStyle: TextStyle(
                color: Theming.whiteTone.withOpacity(
                  !enabled && ctrl.text.isNotEmpty ? 1 : 0.3,
                ),
              ),
              prefixIcon: Icon(
                prefixIcon,
                color: isSelected || ctrl.text.isNotEmpty
                    ? Theming.primaryColor
                    : Theming.whiteTone.withOpacity(0.25),
              ),
              border: InputBorder.none,
            ),
          ),
        ),
        const SizedBox(height: 30),
      ],
    );
  }

  ///[leftRight] must be equal 1 for left or -1 for right.
  StatelessWidget _locationShadow(double leftRight) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Theming.whiteTone,
            blurRadius: 15,
            spreadRadius: 20,
            offset: Offset(5 * leftRight, 20),
          ),
        ],
      ),
    );
  }
}
