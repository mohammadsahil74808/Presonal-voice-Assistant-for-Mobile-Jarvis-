/// Tool Router interface abstraction for Android phone actions
abstract class ToolRouter {
  Future<bool> executeTool(String toolName, Map<String, dynamic> arguments);
}
