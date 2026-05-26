/// Classe gerenciadora do Banco de Dados online (Supabase)
/// Será configurada detalhadamente na Etapa 6.
class SupabaseDb {
  static final SupabaseDb _instance = SupabaseDb._internal();

  factory SupabaseDb() {
    return _instance;
  }

  SupabaseDb._internal();

  /// Inicializa as configurações do Supabase
  Future<void> initialize() async {
    // Aqui adicionaremos as chaves Supabase.url e Supabase.anonKey futuramente.
  }
}
