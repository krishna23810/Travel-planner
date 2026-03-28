
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:travel_planner/data/app_exceptions.dart';
import 'package:travel_planner/data/network/baseApiServices.dart';

class NetworkApiServices extends BaseApiServices {
  @override
  Future getApiResponse(String url) async {

    dynamic responseJson;

    try {
      
      final response = await http.get(Uri.parse(url));
      responseJson = returnResponse(response);

      
    } catch (e) {
      throw FetchDataException(message: e.toString());
    }
    return responseJson;
  }

  @override
  Future postApiResponse(String url, dynamic data) async{

    dynamic responseJson;

    try {
      final response = await http.post(Uri.parse(url), body: data);
      responseJson = returnResponse(response);


    } catch (e) {
      throw FetchDataException(message: e.toString());
    }
    return responseJson;
  }
    
  }

  dynamic returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        dynamic responseJson = jsonDecode(response.body);
        return responseJson;
      case 400:
        throw BadRequestException(message: response.body.toString());
      case 401:
        throw UnauthorizedException(message: response.body.toString());
      case 404:
        throw NotFoundException(message: response.body.toString());
      case 500:
        throw ServerException(message: response.body.toString());
      default:
        throw FetchDataException(message: 'Error occured while Communication + ${response.statusCode}');
    }


  }


  