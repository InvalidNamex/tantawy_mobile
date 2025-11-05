import '../models/agent_model.dart';
import '../providers/api_provider.dart';

class AuthRepository {
  final ApiProvider _apiProvider = ApiProvider();

  Future<AgentModel> login(String username, String password) async {
    final response = await _apiProvider.login(username, password);
    return AgentModel.fromJson(response.data);
  }
}
