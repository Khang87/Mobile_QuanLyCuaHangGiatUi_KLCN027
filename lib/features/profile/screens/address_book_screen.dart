import 'package:flutter/material.dart';
import 'package:app_quanly_giaiui/core/theme/app_colors.dart';
import 'package:app_quanly_giaiui/core/theme/app_typography.dart';
import 'package:app_quanly_giaiui/features/profile/data/address_repository.dart';
import 'package:app_quanly_giaiui/features/profile/data/current_location_service.dart';

class AddressBookScreen extends StatefulWidget {
  const AddressBookScreen({super.key});

  @override
  State<AddressBookScreen> createState() => _AddressBookScreenState();
}

class _AddressBookScreenState extends State<AddressBookScreen> {
  final _repository = AddressRepository();
  final _currentLocationService = CurrentLocationService();
  late Future<List<CustomerAddress>> _addressesFuture;
  bool _isSaving = false;
  int? _deletingAddressId;

  @override
  void initState() {
    super.initState();
    _addressesFuture = _loadAddresses();
  }

  Future<List<CustomerAddress>> _loadAddresses() =>
      _repository.getAddresses().timeout(const Duration(seconds: 15));

  Future<void> _reload() async {
    final future = _loadAddresses();
    setState(() {
      _addressesFuture = future;
    });
    await future;
  }

  Future<void> _openEditor([CustomerAddress? address]) async {
    final formKey = GlobalKey<FormState>();
    final location = TextEditingController(text: address?.address ?? '');
    final note = TextEditingController(text: address?.note ?? '');
    var isDefault = address?.isDefault ?? false;
    var isGettingLocation = false;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => _AddressDialogControllerOwner(
        controllers: [location, note],
        child: StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text(address == null ? 'Thêm địa chỉ' : 'Sửa địa chỉ'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: location,
                      maxLines: 2,
                      decoration: const InputDecoration(labelText: 'Địa chỉ'),
                      validator: _required,
                    ),
                    TextButton.icon(
                      onPressed: isGettingLocation
                          ? null
                          : () async {
                              final messenger = ScaffoldMessenger.of(
                                this.context,
                              );
                              setDialogState(() => isGettingLocation = true);
                              try {
                                final currentAddress =
                                    (await _currentLocationService
                                            .getCurrentAddress())
                                        .address;
                                if (dialogContext.mounted) {
                                  location.text = currentAddress;
                                }
                              } catch (error) {
                                if (dialogContext.mounted && mounted) {
                                  final message =
                                      error is CurrentLocationException
                                      ? error.message
                                      : 'Không lấy được địa chỉ hiện tại.';
                                  messenger.showSnackBar(
                                    SnackBar(content: Text(message)),
                                  );
                                }
                              } finally {
                                if (dialogContext.mounted) {
                                  setDialogState(
                                    () => isGettingLocation = false,
                                  );
                                }
                              }
                            },
                      icon: isGettingLocation
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location),
                      label: Text(
                        isGettingLocation
                            ? 'Đang lấy vị trí...'
                            : 'Điền vị trí hiện tại',
                      ),
                    ),
                    TextFormField(
                      controller: note,
                      decoration: const InputDecoration(labelText: 'Ghi chú'),
                    ),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: isDefault,
                      title: const Text('Địa chỉ mặc định'),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (value) =>
                          setDialogState(() => isDefault = value ?? false),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Hủy'),
              ),
              FilledButton(
                onPressed: _isSaving || _deletingAddressId != null
                    ? null
                    : () async {
                        final messenger = ScaffoldMessenger.of(this.context);
                        if (!(formKey.currentState?.validate() ?? false)) {
                          return;
                        }
                        setState(() => _isSaving = true);
                        try {
                          await _repository
                              .saveAddress(
                                id: address?.id,
                                address: location.text.trim(),
                                note: note.text.trim().isEmpty
                                    ? null
                                    : note.text.trim(),
                                isDefault: isDefault,
                              )
                              .timeout(const Duration(seconds: 15));
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }
                          if (mounted) {
                            try {
                              await _reload();
                            } catch (_) {
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Đã lưu địa chỉ nhưng chưa tải lại được danh sách.',
                                  ),
                                ),
                              );
                            }
                          }
                        } catch (error) {
                          if (mounted) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Không lưu được địa chỉ: $error'),
                              ),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _isSaving = false);
                        }
                      },
                child: _isSaving
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Lưu'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Thông tin bắt buộc.' : null;

  Future<void> _deleteAddress(CustomerAddress address) async {
    if (_deletingAddressId != null) return;
    setState(() => _deletingAddressId = address.id);
    try {
      await _repository
          .deleteAddress(address.id)
          .timeout(const Duration(seconds: 15));
      try {
        await _reload();
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Đã xóa địa chỉ nhưng chưa tải lại được danh sách.',
              ),
            ),
          );
        }
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không xóa được địa chỉ: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _deletingAddressId = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Địa chỉ nhận đồ')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _isSaving || _deletingAddressId != null
            ? null
            : () => _openEditor(),
        icon: const Icon(Icons.add_location_alt_outlined),
        label: const Text('Thêm địa chỉ'),
      ),
      body: FutureBuilder<List<CustomerAddress>>(
        future: _addressesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: TextButton(
                onPressed: _reload,
                child: const Text('Không tải được địa chỉ. Thử lại'),
              ),
            );
          }

          final addresses = snapshot.data ?? const <CustomerAddress>[];
          if (addresses.isEmpty) {
            return const Center(child: Text('Chưa lưu địa chỉ nhận đồ.'));
          }

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              itemCount: addresses.length,
              separatorBuilder: (context, index) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final address = addresses[index];
                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    border: Border.all(color: AppColors.divider),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              address.address,
                              style: AppTypography.title,
                            ),
                          ),
                          if (address.isDefault)
                            const Chip(label: Text('Mặc định')),
                          if (_deletingAddressId == address.id)
                            const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            PopupMenuButton<String>(
                              enabled: _deletingAddressId == null && !_isSaving,
                              onSelected: (action) {
                                if (action == 'edit') _openEditor(address);
                                if (action == 'delete') _deleteAddress(address);
                              },
                              itemBuilder: (context) => const [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Text('Sửa'),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Text('Xóa'),
                                ),
                              ],
                            ),
                        ],
                      ),
                      if (address.note != null && address.note!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          address.note!,
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _AddressDialogControllerOwner extends StatefulWidget {
  const _AddressDialogControllerOwner({
    required this.controllers,
    required this.child,
  });

  final List<TextEditingController> controllers;
  final Widget child;

  @override
  State<_AddressDialogControllerOwner> createState() =>
      _AddressDialogControllerOwnerState();
}

class _AddressDialogControllerOwnerState
    extends State<_AddressDialogControllerOwner> {
  @override
  void dispose() {
    for (final controller in widget.controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
