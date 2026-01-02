import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir_go/providers/setting_provider.dart';
import 'package:kasir_go/utils/dialog_helper.dart';
import 'package:kasir_go/utils/snackbar_helper.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:kasir_go/screen/settings/components/settings_header.dart';
import 'package:kasir_go/screen/settings/components/settings_section.dart';
import 'package:kasir_go/screen/settings/components/settings_text_field.dart';
import 'package:kasir_go/screen/settings/components/calculation_preview.dart';
import 'package:kasir_go/screen/settings/components/settings_action_buttons.dart';
import 'package:kasir_go/providers/app_mode_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  // Controllers
  late TextEditingController _storeNameController;
  late TextEditingController _storeAddressController;
  late TextEditingController _storePhoneController;
  late TextEditingController _taxController;
  late TextEditingController _takeAwayChargeController;
  late TextEditingController _footerController;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingProvider);
    _initializeControllers(settings);
  }

  void _initializeControllers(SettingState settings) {
    _storeNameController = TextEditingController(text: settings.storeName);
    _storeAddressController =
        TextEditingController(text: settings.storeAddress);
    _storePhoneController = TextEditingController(text: settings.storePhone);
    _taxController = TextEditingController(text: settings.taxRate.toString());
    _takeAwayChargeController =
        TextEditingController(text: settings.takeAwayCharge.toStringAsFixed(0));
    _footerController = TextEditingController(text: settings.receiptFooter);
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _storeAddressController.dispose();
    _storePhoneController.dispose();
    _taxController.dispose();
    _takeAwayChargeController.dispose();
    _footerController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    final tax = int.tryParse(_taxController.text) ?? 11;
    final takeAwayCharge = double.tryParse(
            _takeAwayChargeController.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
        0.0;

    await ref.read(settingProvider.notifier).saveSettings(
          storeName: _storeNameController.text,
          storeAddress: _storeAddressController.text,
          storePhone: _storePhoneController.text,
          taxRate: tax,
          takeAwayCharge: takeAwayCharge,
          receiptFooter: _footerController.text,
        );

    if (mounted) {
      showSuccessSnackBar(
        context,
        'Pengaturan berhasil disimpan',
      );
    }
  }

  Future<void> _resetDefault() async {
    final confirm = await showConfirmDialog(
      context,
      message: 'Apakah Anda yakin ingin mengembalikan pengaturan ke awal?',
      title: 'Reset Default',
    );

    if (confirm == true) {
      await ref.read(settingProvider.notifier).resetToDefault();
      if (mounted) {
        final settings = ref.read(settingProvider);
        setState(() {
          _initializeControllers(settings);
        });

        showSuccessSnackBar(
          context,
          'Pengaturan dikembalikan ke default',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Listen to changes to keep UI in sync if external updates happen
    final settings = ref.watch(settingProvider);

    // We update controllers if the state isLoading changes from true to false (initial load)
    ref.listen(settingProvider, (previous, next) {
      if (previous?.isLoading == true && next.isLoading == false) {
        _initializeControllers(next);
        setState(() {});
      }
    });

    if (settings.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          const SettingsHeader(),
          Expanded(
              child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Left Column: General & Informasi Toko
                  Expanded(
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(LucideIcons.arrowLeftRight,
                                      color: Colors.blue.shade600, size: 20),
                                ),
                                title: const Text("Ganti Mode Aplikasi",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w500)),
                                subtitle: const Text(
                                    "Pindah antara Kasir (POS) dan Kitchen (KDS)"),
                                trailing: const Icon(LucideIcons.chevronRight,
                                    size: 16),
                                onTap: () async {
                                  final confirm = await showConfirmDialog(
                                      context,
                                      message:
                                          "Aplikasi akan restart ke menu pemilihan mode. Lanjutkan?",
                                      title: "Ganti Mode");
                                  if (confirm == true) {
                                    await ref
                                        .read(appModeProvider.notifier)
                                        .clearMode();
                                    if (context.mounted) {
                                      Navigator.of(context)
                                          .pushNamedAndRemoveUntil(
                                              '/mode_selection',
                                              (route) => false);
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        SettingsSection(
                          title: "Informasi Toko",
                          subtitle: "Detail toko yang tampil di struk",
                          icon: LucideIcons.store,
                          iconColor: Colors.orange.shade800,
                          iconBgColor: Colors.orange.shade50,
                          children: [
                            SettingsTextField(
                                label: "Nama Toko",
                                controller: _storeNameController),
                            const SizedBox(height: 16),
                            SettingsTextField(
                                label: "Alamat Toko",
                                controller: _storeAddressController),
                            const SizedBox(height: 16),
                            SettingsTextField(
                              label: "No. Telepon",
                              controller: _storePhoneController,
                              keyboardType: TextInputType.phone,
                            ),
                            const SizedBox(height: 16),
                            SettingsTextField(
                              label: "Footer Struk",
                              controller: _footerController,
                              maxLines: 3,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  // Right Column: Pajak & Biaya + Preview + Tombol
                  Expanded(
                    child: Column(
                      children: [
                        SettingsSection(
                          title: "Pajak & Biaya",
                          subtitle: "Pengaturan pajak dan biaya tambahan",
                          icon: LucideIcons.percent,
                          iconColor: const Color.fromARGB(255, 53, 223, 59),
                          iconBgColor: const Color.fromARGB(200, 232, 245, 233),
                          children: [
                            SettingsTextField(
                              label: "Tax Rate (%)",
                              controller: _taxController,
                              keyboardType: TextInputType.number,
                              suffixText: "%",
                              helperText:
                                  "Pajak akan dihitung dari subtotal pesanan",
                              onChanged: () => setState(() {}),
                            ),
                            const SizedBox(height: 16),
                            SettingsTextField(
                              label: "Biaya Take Away",
                              controller: _takeAwayChargeController,
                              keyboardType: TextInputType.number,
                              prefixText: "Rp ",
                              helperText:
                                  "Biaya tambahan untuk pesanan Take Away: Rp ${_takeAwayChargeController.text}",
                              onChanged: () => setState(() {}),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: CalculationPreview(
                            taxController: _taxController,
                            takeAwayChargeController: _takeAwayChargeController,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SettingsActionButtons(
                          onReset: _resetDefault,
                          onSave: _saveSettings,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )),
        ],
      ),
    );
  }
}
