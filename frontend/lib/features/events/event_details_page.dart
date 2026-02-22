import 'package:flutter/material.dart';
import '../../core/ui/backgrounds/gradient_background.dart';
import 'event_model.dart';
import 'event_service.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../features/auth/auth_service.dart';
import '../../shared/models/user_model.dart';

class EventDetailsPage extends StatefulWidget {
  final EventModel event;

  const EventDetailsPage({super.key, required this.event});

  @override
  State<EventDetailsPage> createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  final EventService _eventService = EventService();
  final AuthService _authService = AuthService();

  late EventModel _event;
  UserModel? _currentUser;
  bool _isLoading = true;
  bool _isSubscribed = false;
  bool _isActionLoading = false;

  @override
  void initState() {
    super.initState();
    _event = widget.event;
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final user = await _authService.getUser();
      final fullEvent = await _eventService.getEventById(widget.event.id);

      if (mounted) {
        setState(() {
          _currentUser = user;
          _event = fullEvent;

          if (user != null && fullEvent.participants != null) {
            _isSubscribed = fullEvent.participants!.any((p) => p.id == user.id);
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar detalhes: $e')),
        );
      }
    }
  }

  Future<void> _showAddSpeakerDialog() async {
    final registrationController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Adicionar Integrante"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Digite a matrícula do usuário para adicioná-lo como palestrante ou membro da equipe.",
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: registrationController,
              decoration: const InputDecoration(
                labelText: "Matrícula",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (registrationController.text.isEmpty) return;

              Navigator.pop(context);
              setState(() => _isActionLoading = true);

              try {
                await _eventService.addSpeaker(
                    _event.id, registrationController.text.trim());
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Integrante adicionado com sucesso!')),
                );
                await _loadData(); // Reload to show new speaker
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                          'Erro: ${e.toString().replaceAll("Exception: ", "")}')),
                );
              } finally {
                setState(() => _isActionLoading = false);
              }
            },
            child: const Text("Adicionar"),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSubscription() async {
    setState(() => _isActionLoading = true);
    try {
      await _eventService.subscribe(_event.id);

      // Reload to update state
      await _loadData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Status de inscrição atualizado!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  void _showQRCode() {
    if (_currentUser == null) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Meu Ingresso"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: QrImageView(
                data: _currentUser!.id,
                version: QrVersions.auto,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _currentUser!.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(_currentUser!.registration),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fechar"),
          ),
        ],
      ),
    );
  }

  void _openScanner() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text("Escanear Ingresso")),
          body: MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _performCheckIn(barcode.rawValue!);
                  Navigator.pop(context); // Close scanner after detection
                  break;
                }
              }
            },
          ),
        ),
      ),
    );
  }

  Future<void> _performCheckIn(String userId) async {
    setState(() => _isActionLoading = true);
    try {
      final result = await _eventService.checkIn(_event.id, userId);
      if (mounted) {
        final user = result['user'];
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Check-in realizado: ${user['name']} (${user['registration']})'),
            backgroundColor: Colors.green,
          ),
        );
        _loadData(); // Update participants list
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Erro: ${e.toString().replaceAll("Exception: ", "")}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isActionLoading = false);
    }
  }

  bool get _isOrganizerOrAdmin {
    return _currentUser != null &&
        (_currentUser!.role == Role.ADMIN ||
            _currentUser!.id == _event.organizerId);
  }

  bool get _isStaffForEvent {
    if (_isOrganizerOrAdmin) return true;
    if (_currentUser == null) return false;
    return _event.speakers?.any((s) => s.id == _currentUser!.id) ?? false;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: GradientBackground(
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Header Content
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: const Text(
                        "Evento",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _event.title,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today,
                            color: Colors.white70, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _event.formattedDate,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                            color: Colors.white70, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          _event.location ?? 'Local a definir',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // White Sheet
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(32),
                      topRight: Radius.circular(32),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Organizer Section
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: Theme.of(context)
                                    .colorScheme
                                    .primaryContainer,
                                child: Text(
                                  (_event.organizerName ?? "O")[0],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimaryContainer,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Organizador',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    _event.organizerName ?? "Não informado",
                                    style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ) ??
                                        const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Divider(height: 24),

                          // Description
                          Text(
                            'Sobre o evento',
                            style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ) ??
                                const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _event.description ?? "Sem descrição",
                            style:
                                Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          height: 1.6,
                                        ) ??
                                    const TextStyle(
                                      fontSize: 16,
                                      height: 1.6,
                                    ),
                          ),

                          // Speakers / Team Section
                          if (_event.speakers != null &&
                              _event.speakers!.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            Text(
                              "Equipe / Palestrantes",
                              style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ) ??
                                  const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _event.speakers!.length,
                              itemBuilder: (context, index) {
                                final speaker = _event.speakers![index];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20,
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer,
                                        child: Text(
                                          speaker.name[0].toUpperCase(),
                                          style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onPrimaryContainer,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            speaker.name,
                                            style: Theme.of(context)
                                                    .textTheme
                                                    .titleMedium
                                                    ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ) ??
                                                const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 16,
                                                ),
                                          ),
                                          if (speaker.role != Role.USER)
                                            Text(
                                              speaker.role.name,
                                              style: TextStyle(
                                                color: Colors.grey.shade600,
                                                fontSize: 12,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],

                          const SizedBox(height: 24),

                          // Participants Stats
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildInfoStat(
                                  'Vagas',
                                  '${_event.capacity}',
                                  Icons.people_outline,
                                  context,
                                ),
                                Container(
                                    height: 40,
                                    width: 1,
                                    color: Theme.of(context).dividerColor),
                                _buildInfoStat(
                                  'Inscritos',
                                  '${_event.participantsCount}',
                                  Icons.check_circle_outline,
                                  context,
                                ),
                              ],
                            ),
                          ),

                          // Participants List (Admin/Professor Only)
                          if (_isOrganizerOrAdmin) ...[
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              child: OutlinedButton.icon(
                                onPressed: _showAddSpeakerDialog,
                                icon: const Icon(Icons.person_add_alt_1),
                                label: const Text(
                                    "Adicionar Integrante (Equipe/Palestrante)"),
                                style: OutlinedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  side: const BorderSide(color: Colors.indigo),
                                  foregroundColor: Colors.indigo,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          if (_isStaffForEvent) ...[
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: _openScanner,
                                icon: const Icon(Icons.qr_code_scanner),
                                label: const Text("Escanear Check-in"),
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  backgroundColor: Colors.indigo,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          if (_isOrganizerOrAdmin) ...[
                            const SizedBox(height: 24),
                            Text(
                              'Participantes',
                              style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ) ??
                                  const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 16),
                            if (_event.participants != null &&
                                _event.participants!.isNotEmpty)
                              ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: _event.participants!.length,
                                itemBuilder: (context, index) {
                                  final p = _event.participants![index];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      child: Text(p.name[0]),
                                    ),
                                    title: Text(p.name),
                                    subtitle: Text(p.email),
                                  );
                                },
                              )
                            else
                              const Text("Nenhum participante inscrito."),
                          ],

                          const SizedBox(height: 100), // Space for FAB
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _isOrganizerOrAdmin
          ? null
          : Padding(
              padding: const EdgeInsets.only(bottom: 16, left: 32),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: _isSubscribed
                    ? FloatingActionButton.extended(
                        onPressed: _showQRCode,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        icon: Icon(Icons.qr_code,
                            color: Theme.of(context).colorScheme.onPrimary),
                        label: Text("Meu Ingresso",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.bold)),
                      )
                    : FloatingActionButton.extended(
                        onPressed:
                            _isActionLoading ? null : _handleSubscription,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        label: _isActionLoading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    strokeWidth: 2),
                              )
                            : Text(
                                'Inscrever-se',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                        icon: _isActionLoading
                            ? const SizedBox.shrink()
                            : Icon(
                                Icons.person_add,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                      ),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget _buildInfoStat(
      String label, String value, IconData icon, BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ) ??
              const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
