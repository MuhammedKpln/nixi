// ignore_for_file: inference_failure_on_function_invocation

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:nextcloudnotes/models/capabilities.model.dart';
import 'package:nextcloudnotes/models/login.model.dart';
import 'package:nextcloudnotes/models/login_poll.model.dart';

/// The LoginRepository class is a Dart class that handles fetching login information and checking
/// capabilities for a server using Dio.
@lazySingleton
class LoginRepository {
  final Dio _dio = Dio();

  /// This function fetches a login poll from a server URL using a POST request and returns it as a
  /// LoginPoll object.
  ///
  /// Args:
  ///   serverUrl (String): The `serverUrl` parameter is a string that represents the URL of the server to
  /// which the HTTP POST request will be sent. It is used to fetch a `LoginPoll` object from the server.
  ///
  /// Returns:
  ///   A `Future` object that will eventually resolve to a `LoginPoll` object. The `LoginPoll` object is
  /// created by parsing the JSON response data obtained from a POST request to the specified server URL.
  Future<LoginPoll> fetchLoginPoll(String serverUrl) async {
    final response = await _dio.post(
      '$serverUrl/index.php/login/v2',
      options: Options(
        headers: {'User-Agent': 'Nixy/1.0'},
      ),
    );

    return LoginPoll.fromJson(response.data as Map<String, dynamic>);
  }

  /// This function fetches the app password by sending a POST request to a specified server URL with a
  /// token and returns a Login object parsed from the response data.
  ///
  /// Args:
  ///   serverUrl (String): The URL of the server where the login API is hosted.
  ///   token (String): The `token` parameter is a string that is used as a unique identifier for the
  /// user's session. It is passed as a parameter to the server to authenticate the user and retrieve
  /// their login information.
  ///
  /// Returns:
  ///   The function `fetchAppPassword` is returning a `Future` object that will eventually resolve to a
  /// `Login` object. The `Login` object is created by parsing the JSON response from the server using the
  /// `fromJson` method of the `Login` class.
  Future<Login> fetchAppPassword(String serverUrl, String token) async {
    final response = await _dio
        .post('$serverUrl/index.php/login/v2/poll', data: {'token': token});

    return Login.fromJson(response.data as Map<String, dynamic>);
  }

  /// This function checks the capabilities of a server using a provided URL and token.
  ///
  /// Args:
  ///   serverUrl (String): The URL of the server where the capabilities of the cloud service are being
  /// checked.
  ///   token (String): The token parameter is a string that represents the authentication token used to
  /// access the server. It is usually generated by the server and provided to the client as a means of
  /// authentication. The token is included in the request headers as the value of the 'Authorization'
  /// key.
  ///
  /// Returns:
  ///   a Future object that will eventually resolve to an instance of the Capabilities class, which is
  /// created from the JSON response data obtained from an HTTP GET request to a specified server URL with
  /// the provided token as authorization.
  Future<Capabilities> checkNoteCapability(
    String serverUrl,
    String token,
  ) async {
    final response = await _dio.get(
      '$serverUrl/ocs/v2.php/cloud/capabilities',
      options: Options(
        headers: {
          'OCS-APIRequest': 'true',
          'Accept': 'application/json',
          'Authorization': 'Basic $token'
        },
      ),
    );

    return Capabilities.fromJson(response.data as Map<String, dynamic>);
  }
}
