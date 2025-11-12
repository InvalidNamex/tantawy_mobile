import '../models/agent_model.dart';
import '../providers/api_provider.dart';
import '../../utils/logger.dart';

class AuthRepository {
  final ApiProvider _apiProvider = ApiProvider();

  Future<AgentModel> login(String username, String password) async {
    final response = await _apiProvider.login(username, password);
    logger.d('🔍 LOGIN RESPONSE DATA: ${response.data}');
    logger.d('🔍 LOGIN RESPONSE TYPE: ${response.data.runtimeType}');
    
    // Add username and password to the response data before parsing
    final agentData = Map<String, dynamic>.from(response.data);
    agentData['username'] = username;
    agentData['password'] = password;
    
    final agent = AgentModel.fromJson(agentData);
    logger.d('✅ PARSED AGENT: ID=${agent.id}, Name=${agent.name}, Username=${agent.username}, Token=${agent.token}, StoreID=${agent.storeID}');
    
    return agent;
  }
}
