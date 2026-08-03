/// Memory Service abstraction (Short-term & Long-term context)
abstract class MemoryService {
  Future<void> saveContext(String key, String value);
  Future<String?> getContext(String key);
}
