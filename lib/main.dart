import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://ivuuxgvjbytjgzheggqr.supabase.co',
    anonKey: 'sb_publishable_j_Z6PHX0a1mv2N5ET4ePQw_NEwZhEnr',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static final ValueNotifier<ThemeMode> themeNotifier =
      ValueNotifier(ThemeMode.light);
  static final ValueNotifier<double> fontSizeNotifier = ValueNotifier(16.0);

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, currentMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Messenger',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          darkTheme: ThemeData.dark(useMaterial3: true),
          themeMode: currentMode,
          home: session != null ? const MainTabsScreen() : const AuthScreen(),
        );
      },
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthdateController = TextEditingController();
  bool _isSignUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _birthdateController.dispose();
    super.dispose();
  }

  void _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) return;
    try {
      if (_isSignUp) {
        await Supabase.instance.client.auth.signUp(
          email: email,
          password: password,
          data: {
            'full_name': 'Пользователь',
            'username': _usernameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'birth_date': _birthdateController.text.trim(),
            'avatar_url': 'default',
          },
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Успешно! Теперь войдите.')),
        );
        setState(() => _isSignUp = false);
      } else {
        await Supabase.instance.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const MainTabsScreen()),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSignUp ? 'Регистрация' : 'Вход'),
        backgroundColor: Colors.blue.shade100,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Пароль',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                ),
                if (_isSignUp) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      labelText: 'Юзернейм',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Телефон',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _birthdateController,
                    decoration: const InputDecoration(
                      labelText: 'Дата рождения',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submit,
                  child: Text(_isSignUp ? 'Создать аккаунт' : 'Войти'),
                ),
                TextButton(
                  onPressed: () => setState(() => _isSignUp = !_isSignUp),
                  child: Text(
                    _isSignUp ? 'Есть аккаунт? Войти' : 'Нет аккаунта? Создать',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MainTabsScreen extends StatelessWidget {
  const MainTabsScreen({super.key});

  @override
  Widget build(BuildContext context) => const MainTabsScreenContent();
}

class MainTabsScreenContent extends StatefulWidget {
  const MainTabsScreenContent({super.key});

  @override
  State<MainTabsScreenContent> createState() => _MainTabsScreenState();
}

class _MainTabsScreenState extends State<MainTabsScreenContent> {
  int _currentIndex = 0;
  final List<Widget> _screens = const [
    ActivechatsScreen(),
    SearchScreen(),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (idx) => setState(() => _currentIndex = idx),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Чаты'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Поиск'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Настройки'),
        ],
      ),
    );
  }
}

class ActivechatsScreen extends StatelessWidget {
  const ActivechatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Диалоги'),
        backgroundColor: Colors.blue.shade50,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.blueAccent,
              child: Icon(Icons.bookmark, color: Colors.white),
            ),
            title: const Text(
              'Избранное',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text('Чат с самим собой. Заметки, фото, ссылки...'),
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              final myId = Supabase.instance.client.auth.currentUser?.id ?? '';
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ChatScreen(
                    chatWith: {
                      'id': myId,
                      'full_name': 'Избранное',
                      'username': 'saved',
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();
  List<dynamic> _foundUsers = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search() async {
    final query = _searchController.text.trim();
    if (query.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final res = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('username', query);

      if (!mounted) return;
      setState(() {
        _foundUsers = res as List<dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка поиска: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Поиск контактов'),
        backgroundColor: Colors.blue.shade50,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Введите username...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _isLoading ? null : _search,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Найти'),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _foundUsers.isEmpty
                  ? const Center(
                      child: Text(
                        'Введите данные для поиска',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _foundUsers.length,
                      itemBuilder: (context, index) {
                        final user = _foundUsers[index];
                        final avatar = user['avatar_url']?.toString();
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: (avatar != null &&
                                    avatar.isNotEmpty &&
                                    avatar != 'default' &&
                                    avatar.startsWith('http'))
                                ? NetworkImage(avatar)
                                : null,
                            child: (avatar == null ||
                                    avatar.isEmpty ||
                                    avatar == 'default' ||
                                    !avatar.startsWith('http'))
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          title: Text(user['full_name'] ?? 'Пользователь'),
                          subtitle: Text('@${user['username'] ?? 'username'}'),
                          trailing: const Icon(Icons.chat, color: Colors.blue),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  chatWith: {
                                    'id': (user['id'] ?? '').toString(),
                                    'full_name':
                                        user['full_name'] ?? 'Чат',
                                    'username':
                                        (user['username'] ?? '').toString(),
                                  },
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthController = TextEditingController();

  String _avatarUrl = 'default';

  @override
  void initState() {
    super.initState();
    _loadMobileSettings();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _birthController.dispose();
    super.dispose();
  }

  Future<void> _loadMobileSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final u = Supabase.instance.client.auth.currentUser;
    if (!mounted) return;
    setState(() {
      MyApp.fontSizeNotifier.value = prefs.getDouble('fontSize') ?? 16.0;
      MyApp.themeNotifier.value =
          (prefs.getBool('isDark') ?? false) ? ThemeMode.dark : ThemeMode.light;

      if (u != null) {
        _nameController.text = u.userMetadata?['full_name'] ?? 'Пользователь';
        _usernameController.text = u.userMetadata?['username'] ?? 'username';
        _phoneController.text = u.userMetadata?['phone'] ?? '';
        _birthController.text = u.userMetadata?['birth_date'] ?? '';
        _avatarUrl = (u.userMetadata?['avatar_url'] ?? 'default').toString();
      }
    });
  }

  Future<void> _changeAvatar() async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );

    if (image != null && mounted) {
      setState(() {
        _avatarUrl = image.path;
      });
    }
  }

  Future<void> _saveProfileData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDark', MyApp.themeNotifier.value == ThemeMode.dark);
      await prefs.setDouble('fontSize', MyApp.fontSizeNotifier.value);

      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': _nameController.text.trim(),
            'username': _usernameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'birth_date': _birthController.text.trim(),
            'avatar_url': _avatarUrl,
          },
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Все настройки сохранены на сервере и в браузере!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка сохранения: $e')),
      );
    }
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }

  ImageProvider? _avatarProvider() {
    if (_avatarUrl == 'default' || _avatarUrl.isEmpty) return null;
    if (_avatarUrl.startsWith('http')) return NetworkImage(_avatarUrl);
    return FileImage(File(_avatarUrl));
  }

  @override
  Widget build(BuildContext context) {
    final provider = _avatarProvider();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки профиля'),
        backgroundColor: Colors.blue.shade50,
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.blue),
            onPressed: _saveProfileData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.grey.shade300,
                    backgroundImage: provider,
                    child: provider == null
                        ? const Icon(Icons.person, size: 55, color: Colors.white)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.blue,
                      child: IconButton(
                        icon: const Icon(
                          Icons.camera_alt,
                          size: 16,
                          color: Colors.white,
                        ),
                        onPressed: _changeAvatar,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              'ЛИЧНЫЕ ДАННЫЕ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Имя',
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Имя пользователя (username)',
                prefixIcon: Icon(Icons.alternate_email),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Номер телефона',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _birthController,
              decoration: const InputDecoration(
                labelText: 'Дата рождения',
                prefixIcon: Icon(Icons.cake),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'НАСТРОЙКИ ПРИЛОЖЕНИЯ И ЧАТОВ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 10),
            Card(
              child: Column(
                children: [
                  ValueListenableBuilder<ThemeMode>(
                    valueListenable: MyApp.themeNotifier,
                    builder: (_, mode, __) => SwitchListTile(
                      title: const Text('Тёмная тема оформления'),
                      secondary: const Icon(Icons.dark_mode),
                      value: mode == ThemeMode.dark,
                      onChanged: (v) {
                        MyApp.themeNotifier.value =
                            v ? ThemeMode.dark : ThemeMode.light;
                      },
                    ),
                  ),
                  ValueListenableBuilder<double>(
                    valueListenable: MyApp.fontSizeNotifier,
                    builder: (_, size, __) => ListTile(
                      leading: const Icon(Icons.text_fields),
                      title: const Text('Размер шрифта в чатах'),
                      subtitle: Slider(
                        min: 12.0,
                        max: 24.0,
                        divisions: 6,
                        label: size.round().toString(),
                        value: size,
                        onChanged: (v) =>
                            MyApp.fontSizeNotifier.value = v,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Выйти из аккаунта',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: _logout,
            ),
          ],
        ),
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final Map<String, String> chatWith;

  const ChatScreen({super.key, required this.chatWith});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final FocusNode _messageFocusNode = FocusNode();
  final _msg = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<dynamic> _serverMessages = [];
  Set<int> _selectedIndexes = {};

  bool _isLoading = true;
  bool _showScrollDownButton = false;
  bool _isTextFieldBlocked = false;
  int? _editingMessageId;

  String get _otherId => widget.chatWith['id'] ?? '';
  String get _myId =>
      Supabase.instance.client.auth.currentUser?.id ?? '';
  bool get _isSavedChat => _otherId.isNotEmpty && _otherId == _myId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadMessages();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _messageFocusNode.dispose();
    _msg.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final pixelsFromBottom = _scrollController.position.maxScrollExtent -
        _scrollController.position.pixels;
    final shouldShow = pixelsFromBottom > 150;
    if (shouldShow != _showScrollDownButton) {
      setState(() => _showScrollDownButton = shouldShow);
    }
  }

  Future<void> _loadMessages() async {
    final myId = _myId;
    final otherId = _otherId;

    if (myId.isEmpty || otherId.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final res = await Supabase.instance.client
          .from('messages')
          .select()
          .or('and(sender_id.eq.$myId,receiver_id.eq.$otherId),'
              'and(sender_id.eq.$otherId,receiver_id.eq.$myId)')
          .order('created_at', ascending: true);

      if (!mounted) return;

      setState(() {
        _serverMessages = (res as List<dynamic>).where((msg) {
          final hidden = (msg['hidden_by'] ?? '').toString().split(',');
          return !hidden.contains(myId);
        }).toList();
        _isLoading = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!_scrollController.hasClients) return;

        int firstUnreadIndex = -1;
        for (int i = 0; i < _serverMessages.length; i++) {
          if (_serverMessages[i]['sender_id'] != myId &&
              _serverMessages[i]['is_read'] == false) {
            firstUnreadIndex = i;
            break;
          }
        }

        if (firstUnreadIndex != -1) {
          double target = firstUnreadIndex * 85.0;
          if (target > _scrollController.position.maxScrollExtent) {
            target = _scrollController.position.maxScrollExtent;
          }
          _scrollController.jumpTo(target);
        } else {
          _scrollController
              .jumpTo(_scrollController.position.maxScrollExtent);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markIncomingRead() async {
    final myId = _myId;
    final otherId = _otherId;
    if (myId.isEmpty || otherId.isEmpty || otherId == myId) return;
    try {
      await Supabase.instance.client
          .from('messages')
          .update({'is_read': true})
          .eq('sender_id', otherId)
          .eq('receiver_id', myId)
          .eq('is_read', false);
    } catch (_) {}
  }

  Future<void> _scrollToBottom() async {
    if (_scrollController.hasClients) {
      await _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
    await _markIncomingRead();
  }

  Future<void> _send() async {
    final text = _msg.text.trim();
    if (text.isEmpty) return;

    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    _msg.clear();

    try {
      if (_editingMessageId != null) {
        await Supabase.instance.client
            .from('messages')
            .update({'text': text})
            .eq('id', _editingMessageId!);
        _editingMessageId = null;
      } else {
        await Supabase.instance.client.from('messages').insert({
          'text': text,
          'sender_id': user.id,
          'receiver_id': _otherId,
          'is_read': _isSavedChat,
        });
      }

      await _loadMessages();
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) _scrollToBottom();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка отправки: $e')),
      );
    }
  }

  void _safePop(BuildContext context) {
    setState(() => _isTextFieldBlocked = true);

    WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
    _messageFocusNode.unfocus();

    Future.microtask(() {
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      Future.delayed(const Duration(milliseconds: 200), () {
        if (mounted) {
          setState(() => _isTextFieldBlocked = false);
        }
      });
    });
  }

  void _showDeleteDialog({required bool isGroup, int? index}) {
    FocusScope.of(context).unfocus();

    showDialog(
      context: context,
      builder: (dialogContext) {
        final myId = _myId;
        return AlertDialog(
          title: const Text('Удалить?'),
          content: Text(
            isGroup
                ? 'Удалить выбранные сообщения для себя или для всех?'
                : 'Вы хотите удалить это сообщение только для себя или для всех участников?',
          ),
          actions: [
            TextButton(
              child: const Text(
                'Только у меня',
                style: TextStyle(color: Colors.black),
              ),
              onPressed: () async {
                _safePop(dialogContext);
                FocusScope.of(context).unfocus();
                try {
                  if (isGroup) {
                    for (final idx in _selectedIndexes) {
                      final currentHidden =
                          (_serverMessages[idx]['hidden_by'] ?? '')
                              .toString();
                      final updated = currentHidden.isEmpty
                          ? myId
                          : '$currentHidden,$myId';
                      await Supabase.instance.client
                          .from('messages')
                          .update({'hidden_by': updated}).eq(
                              'id', _serverMessages[idx]['id']);
                    }
                  } else if (index != null) {
                    final currentHidden =
                        (_serverMessages[index]['hidden_by'] ?? '')
                            .toString();
                    final updated =
                        currentHidden.isEmpty ? myId : '$currentHidden,$myId';
                    await Supabase.instance.client
                        .from('messages')
                        .update({'hidden_by': updated}).eq(
                            'id', _serverMessages[index]['id']);
                  }
                  setState(() => _selectedIndexes.clear());
                  _loadMessages();
                } catch (_) {}
              },
            ),
            TextButton(
              child: const Text(
                'Удалить у всех',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () async {
                _safePop(dialogContext);
                FocusScope.of(context).unfocus();
                try {
                  if (isGroup) {
                    final ids = _selectedIndexes
                        .map((idx) => _serverMessages[idx]['id'])
                        .toList();
                    await Supabase.instance.client
                        .from('messages')
                        .delete()
                        .inFilter('id', ids);
                  } else if (index != null) {
                    await Supabase.instance.client
                        .from('messages')
                        .delete()
                        .eq('id', _serverMessages[index]['id']);
                  }
                  setState(() => _selectedIndexes.clear());
                  _loadMessages();
                } catch (_) {}
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      floatingActionButton: _showScrollDownButton
          ? Padding(
              padding: const EdgeInsets.only(bottom: 90),
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.white.withOpacity(0.9),
                child: const Icon(Icons.arrow_downward, color: Colors.blue),
                onPressed: () async {
                  await _markIncomingRead();
                  await _loadMessages();
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      _scrollController.position.maxScrollExtent,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                },
              ),
            )
          : null,
      appBar: AppBar(
        title: Text(
          _selectedIndexes.isNotEmpty
              ? 'Выбрано: ${_selectedIndexes.length}'
              : (widget.chatWith['full_name'] ?? 'Чат'),
        ),
        backgroundColor: Colors.blue.shade50,
        leading: _selectedIndexes.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _selectedIndexes.clear()),
              )
            : null,
        actions: _selectedIndexes.isNotEmpty
            ? [
                IconButton(
                  icon: const Icon(Icons.copy),
                  onPressed: () {
                    final buffer = _selectedIndexes
                        .map((i) => _serverMessages[i]['text'] ?? '')
                        .join('\n');
                    Clipboard.setData(ClipboardData(text: buffer));
                    setState(() => _selectedIndexes.clear());
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Сообщения скопированы!')),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _showDeleteDialog(isGroup: true),
                ),
              ]
            : null,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
          _messageFocusNode.unfocus();
        },
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      controller: _scrollController,
                      itemCount: _serverMessages.length,
                      itemBuilder: (ctx, i) {
                        final msg = _serverMessages[i];
                        final myId = _myId;

                        bool showNewMessagesLine = false;
                        bool showDateDivider = false;
                        final dateText =
                            msg['created_at']?.toString().split('T')[0] ?? '';

                        if (i == 0) {
                          showDateDivider = true;
                        } else {
                          final prevDate = _serverMessages[i - 1]['created_at']
                                  ?.toString()
                                  .split('T')[0] ??
                              '';
                          if (dateText != prevDate) showDateDivider = true;
                        }

                        if (msg['sender_id'] != myId &&
                            msg['is_read'] == false) {
                          if (i == 0 || _serverMessages[i - 1]['is_read'] == true) {
                            showNewMessagesLine = true;
                          }
                        }

                        final isMe = msg['sender_id'] == myId;
                        final isSelected = _selectedIndexes.contains(i);

                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (showDateDivider && dateText.isNotEmpty)
                              Center(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      vertical: 16),
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 4, horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.08),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    dateText.contains(',')
                                        ? dateText
                                            .replaceAll('[', '')
                                            .replaceAll(']', '')
                                        : dateText
                                            .split('-')
                                            .reversed
                                            .join('.'),
                                    style: const TextStyle(
                                      color: Colors.black54,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                            if (showNewMessagesLine)
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    vertical: 12),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Новые сообщения',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            GestureDetector(
                              onLongPress: () {
                                FocusScope.of(context).unfocus();
                                setState(() {
                                  if (isSelected) {
                                    _selectedIndexes.remove(i);
                                  } else {
                                    _selectedIndexes.add(i);
                                  }
                                });
                              },
                              onTap: () {
                                final messageId = msg['id'];
                                final messageText = msg['text'] ?? '';

                                if (_selectedIndexes.isNotEmpty) {
                                  FocusScope.of(context).unfocus();
                                  setState(() {
                                    if (_selectedIndexes.contains(i)) {
                                      _selectedIndexes.remove(i);
                                    } else {
                                      _selectedIndexes.add(i);
                                    }
                                  });
                                  return;
                                }

                                FocusScope.of(context).unfocus();
                                showModalBottomSheet(
                                  context: context,
                                  builder: (sheetContext) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .scaffoldBackgroundColor,
                                        borderRadius:
                                            const BorderRadius.vertical(
                                                top: Radius.circular(20)),
                                      ),
                                      padding: const EdgeInsets.only(
                                        top: 16,
                                        left: 16,
                                        right: 16,
                                        bottom: 40,
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children:
                                                ['👍', '🔥', '❤️', '😂'].map(
                                              (emoji) {
                                                return IconButton(
                                                  icon: Text(
                                                    emoji,
                                                    style: const TextStyle(
                                                        fontSize: 24),
                                                  ),
                                                  onPressed: () async {
                                                    _safePop(sheetContext);
                                                    try {
                                                      await Supabase.instance
                                                          .client
                                                          .from('messages')
                                                          .update({
                                                        'reaction': emoji
                                                      }).eq('id', messageId);
                                                      _loadMessages();
                                                    } catch (_) {}
                                                  },
                                                );
                                              },
                                            ).toList(),
                                          ),
                                          const Divider(),
                                          ListTile(
                                            leading: const Icon(Icons.copy,
                                                color: Colors.blue),
                                            title:
                                                const Text('Скопировать текст'),
                                            onTap: () {
                                              _safePop(sheetContext);
                                              Clipboard.setData(
                                                ClipboardData(
                                                    text: messageText),
                                              );
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                      'Текст скопирован!'),
                                                ),
                                              );
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(Icons.edit,
                                                color: Colors.orange),
                                            title: const Text(
                                                'Изменить сообщение'),
                                            onTap: () {
                                              _safePop(sheetContext);
                                              setState(() {
                                                _msg.text = messageText;
                                                _editingMessageId = messageId;
                                              });
                                              _messageFocusNode.requestFocus();
                                            },
                                          ),
                                          ListTile(
                                            leading: const Icon(Icons.delete,
                                                color: Colors.red),
                                            title: const Text(
                                              'Удалить',
                                              style:
                                                  TextStyle(color: Colors.red),
                                            ),
                                            onTap: () {
                                              Navigator.pop(sheetContext);
                                              _showDeleteDialog(
                                                  isGroup: false, index: i);
                                            },
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                              child: Align(
                                alignment: Alignment.centerRight,
                                child: Container(
                                  margin: const EdgeInsets.all(6),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.teal.shade200
                                        : Colors.blue.shade200,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ValueListenableBuilder<double>(
                                    valueListenable: MyApp.fontSizeNotifier,
                                    builder: (context, size, _) {
                                      final isRead = msg['is_read'] == true ||
                                          isMe && _isSavedChat;
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            msg['text'] ?? '',
                                            style: TextStyle(fontSize: size),
                                          ),
                                          if (msg['reaction'] != null &&
                                              msg['reaction']
                                                  .toString()
                                                  .isNotEmpty)
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 4),
                                              child: Text(
                                                msg['reaction'],
                                                style: const TextStyle(
                                                    fontSize: 16),
                                              ),
                                            ),
                                          const SizedBox(height: 4),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                msg['created_at'] != null
                                                    ? () {
                                                        final dt = DateTime
                                                            .parse(msg[
                                                                    'created_at']
                                                                .toString())
                                                            .toLocal();
                                                        return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
                                                      }()
                                                    : '',
                                                style: TextStyle(
                                                  fontSize: size * 0.7,
                                                  color:
                                                      Colors.grey.shade600,
                                                ),
                                              ),
                                              if (isMe) ...[
                                                const SizedBox(width: 4),
                                                Text(
                                                  isRead ? '✓✓' : '✓',
                                                  style: TextStyle(
                                                    fontSize: size * 0.8,
                                                    fontWeight: FontWeight.bold,
                                                    color: isRead
                                                        ? Colors.teal
                                                        : Colors
                                                            .grey.shade600,
                                                  ),
                                                ),
                                              ],
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
            Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom > 0
                    ? MediaQuery.of(context).viewInsets.bottom
                    : 50,
                left: 10,
                right: 10,
              ),
              child: Row(
                children: [
                  if (_editingMessageId != null)
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () {
                        setState(() {
                          _editingMessageId = null;
                          _msg.clear();
                        });
                      },
                    ),
                  Expanded(
                    child: TextField(
                      controller: _msg,
                      focusNode: _messageFocusNode,
                      readOnly: _isTextFieldBlocked,
                      decoration: const InputDecoration(
                        hintText: 'Сообщение...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: _send,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}