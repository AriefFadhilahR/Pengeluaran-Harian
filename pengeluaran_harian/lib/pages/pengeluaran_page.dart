import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/pengeluaran_repo.dart';
import '../models/pengeluaran.dart';

class PengeluaranPage extends StatefulWidget {
  final PengeluaranRepo repo;
  const PengeluaranPage({super.key, required this.repo});

  @override
  State<PengeluaranPage> createState() => _PengeluaranPageState();
}

class _PengeluaranPageState extends State<PengeluaranPage> {
  List<Pengeluaran> _data = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _muat();
  }

  Future<void> _muat() async {
    final d = await widget.repo.semua();
    d.sort((a, b) {
      final c = b.tanggal.compareTo(a.tanggal);
      return c != 0 ? c : (b.id ?? 0).compareTo(a.id ?? 0);
    });
    if (!mounted) return;
    setState(() {
      _data = d;
      _loading = false;
    });
  }

  void _pesan(String teks, {SnackBarAction? aksi}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(teks), action: aksi, behavior: SnackBarBehavior.floating));
  }

  Future<void> _hapus(Pengeluaran p) async {
    setState(() => _data.removeWhere((e) => e.id == p.id));
    await widget.repo.hapus(p.id!);
    if (!mounted) return;
    _pesan('"${p.judul}" dihapus',
        aksi: SnackBarAction(
          label: 'Urungkan',
          onPressed: () async {
            await widget.repo.tambah(Pengeluaran(
              judul: p.judul,
              jumlah: p.jumlah,
              kategori: p.kategori,
              tanggal: p.tanggal,
            ));
            _muat();
          },
        ));
  }

  Future<void> _form([Pengeluaran? p]) async {
    final judul = TextEditingController(text: p?.judul);
    final jumlah = TextEditingController(text: p?.jumlah.toString());
    String kategori = p?.kategori ?? kategoriList.first;
    DateTime tanggal = p?.tanggal ?? DateTime.now();
    final kunci = GlobalKey<FormState>();

    final hasil = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(20, 0, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Form(
            key: kunci,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p == null ? 'Tambah Pengeluaran' : 'Ubah Pengeluaran',
                    style: Theme.of(ctx).textTheme.titleLarge),
                const SizedBox(height: 16),
                TextFormField(
                  controller: judul,
                  decoration: const InputDecoration(labelText: 'Keterangan', border: OutlineInputBorder()),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Keterangan wajib diisi' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: jumlah,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                      labelText: 'Jumlah (Rp)', prefixText: 'Rp ', border: OutlineInputBorder()),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    return (n == null || n <= 0) ? 'Jumlah harus lebih dari 0' : null;
                  },
                ),
                const SizedBox(height: 12),
                const Text('Kategori'),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  children: kategoriList
                      .map((k) => ChoiceChip(
                            avatar: Icon(ikonKategori(k), size: 18),
                            label: Text(k),
                            selected: kategori == k,
                            onSelected: (_) => setS(() => kategori = k),
                          ))
                      .toList(),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today),
                  title: Text(formatTanggal(tanggal)),
                  subtitle: const Text('Ketuk untuk ganti tanggal'),
                  onTap: () async {
                    final d = await showDatePicker(
                      context: ctx,
                      initialDate: tanggal,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (d != null) setS(() => tanggal = d);
                  },
                ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      if (kunci.currentState!.validate()) Navigator.pop(ctx, true);
                    },
                    child: const Text('Simpan'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (hasil != true) return;
    final baru = Pengeluaran(
      id: p?.id,
      judul: judul.text.trim(),
      jumlah: int.parse(jumlah.text),
      kategori: kategori,
      tanggal: tanggal,
    );
    if (p == null) {
      await widget.repo.tambah(baru);
    } else {
      await widget.repo.ubah(baru);
    }
    await _muat();
    if (!mounted) return;
    _pesan(p == null ? 'Pengeluaran ditambahkan' : 'Pengeluaran diperbarui');
  }

  Widget _ringkasan() {
    final cs = Theme.of(context).colorScheme;
    final total = _data.fold<int>(0, (s, e) => s + e.jumlah);
    final perKat = <String, int>{};
    for (final p in _data) {
      perKat[p.kategori] = (perKat[p.kategori] ?? 0) + p.jumlah;
    }
    return Card(
      color: cs.primaryContainer,
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Total pengeluaran', style: TextStyle(color: cs.onPrimaryContainer)),
          Text(rupiah(total),
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(fontWeight: FontWeight.bold, color: cs.onPrimaryContainer)),
          Text('${_data.length} transaksi', style: TextStyle(color: cs.onPrimaryContainer)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: perKat.entries
                .map((e) => Chip(
                      visualDensity: VisualDensity.compact,
                      avatar: Icon(ikonKategori(e.key), size: 16, color: warnaKategori(e.key)),
                      label: Text('${e.key} ${rupiah(e.value)}', style: const TextStyle(fontSize: 12)),
                    ))
                .toList(),
          ),
        ]),
      ),
    );
  }

  Widget _item(Pengeluaran p) {
    final w = warnaKategori(p.kategori);
    return Dismissible(
      key: ValueKey('${widget.repo.nama}-${p.id}'),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _hapus(p),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: ListTile(
          onTap: () => _form(p),
          leading: CircleAvatar(
            backgroundColor: w.withOpacity(0.15),
            child: Icon(ikonKategori(p.kategori), color: w),
          ),
          title: Text(p.judul, maxLines: 1, overflow: TextOverflow.ellipsis),
          subtitle: Text('${p.kategori}  •  ${formatTanggal(p.tanggal)}'),
          trailing: Text(rupiah(p.jumlah), style: const TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(children: [
              _ringkasan(),
              Expanded(
                child: _data.isEmpty
                    ? const Center(child: Text('Belum ada pengeluaran. Ketuk Tambah untuk mulai.'))
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 4, bottom: 88),
                        itemCount: _data.length,
                        itemBuilder: (_, i) => _item(_data[i]),
                      ),
              ),
            ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _form(),
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
    );
  }
}
