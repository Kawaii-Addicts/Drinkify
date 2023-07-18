import 'dart:convert';
import 'dart:io';
import 'package:drinkify/models/friend.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../utils/consts.dart' show mainUrl;
import '../models/party.dart';
import '../models/party_request.dart';
import '../utils/ext.dart' show LatLngConvert;

///Used by the party creator to control owned parties
class PartyCreatorController {
  ///Returns a list of all parties created by the user
  static Future<List<Party>> ownedParties() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: "access");
    final url = "$mainUrl/parties/mine/";
    final res = await http.get(
      Uri.parse(url),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    final parties = <Party>[];
    for (final e in jsonDecode(res.body)["results"]) {
      parties.add(Party.fromMap(e));
    }
    return parties;
  }

  ///Retrieves a list of join requests to user's owned parties
  static Future<List<PartyRequest>> joinRequests() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: "access");
    final url = "$mainUrl/parties/requests/";
    final res = await http.get(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    final requests = <PartyRequest>[];
    for (final pr in jsonDecode(res.body)["results"]) {
      requests.add(PartyRequest.fromMap(pr));
    }
    return requests;
  }

  ///Creates a party using information provided in [party]
  static Future<Party?> createParty(Party party) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: "access");
    final url = "$mainUrl/parties/";
    final req = http.MultipartRequest(
      "POST",
      Uri.parse(url),
    );
    req.headers.addAll({
      "Content-Type": "multipart/form-data",
      "Authorization": "Bearer $token",
    });
    req.fields.addAll(<String, String>{
      "name": party.name,
      "privacy_status": party.privacyStatus.toString(),
      "description": party.description,
      "location": party.location!.toPOINT(),
      "start_time": party.startTime.toIso8601String(),
      "stop_time": party.stopTime.toIso8601String(),
    });

    if (party.image != null) {
      req.files.add(
        http.MultipartFile(
          "image",
          File(party.image!).readAsBytes().asStream(),
          File(party.image!).lengthSync(),
          filename: party.image!,
          contentType: MediaType("image", "jpeg"),
        ),
      );
    }
    final res = await req.send();
    return Party.fromMap(jsonDecode(await res.stream.bytesToString()));
  }

  ///Deletes party with the provided [id]
  static Future<bool> deleteParty(String id) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: "access");
    final url = "$mainUrl/parties/$id/";
    final res = await http.delete(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return res.statusCode == 204;
  }

  //FIXME sending request
  static Future<bool> acceptPartyRequest(PartyRequest req) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: "access");
    final url = "$mainUrl/parties/requests/${req.party!.publicId}/${req.id}/";
    final res = await http.post(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
      },
    );
    return res.statusCode == 201;
  }

  //FIXME
  static Future<bool> rejectPartyRequest(PartyRequest req) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: "access");
    final url = "$mainUrl/parties/requests/${req.party!.publicId}/${req.id}/";
    final res = await http.delete(
      Uri.parse(url),
      headers: {
        "Authorization": "Bearer $token",
      },
    );
    return res.statusCode == 204;
  }

  static Future<bool> sendPartyInvitation(Party p, Friend f) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: "access");
    final url = "$mainUrl/parties/invitations/${p.publicId}";
    final res = await http.post(
      Uri.parse(url),
      body: {
        //TODO implement those fields
      },
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    return res.statusCode == 201;
  }
}
