# 🎬 Panduan Demo Video — Linked VERSE Logs

Panduan lengkap untuk merekam video demo **Linked VERSE Logs - Centralized Logging (ELK Stack)**.

> **Format judul video:** TKA_C01_Modul 4 Logging & Monitoring  
> **Upload:** YouTube sebagai **Unlisted** dalam playlist **C01 - TKA 2026**

---

## 1. Penjelasan Proyek

### Apa itu Linked VERSE Logs?

Linked VERSE Logs adalah sistem **centralized logging** yang dibangun menggunakan **ELK Stack** (Elasticsearch, Logstash, Kibana) dan **Filebeat** untuk mencatat aktivitas pemain saat mengakses fitur **Linked VERSE** pada game CHUNITHM X-VERSE.

Sistem ini mencatat berbagai kejadian seperti:
- Pemain mengakses gate (Gate Access)
- Pemain membuka kunci gate (Gate Unlock)
- Pemain memulai challenge (Challenge Start)
- Pemain berhasil/gagal challenge (Challenge Clear/Failed)
- Request tidak valid / mencurigakan (Invalid Gate Request)

### Mengapa perlu Centralized Logging?

- **Troubleshooting**: Melacak error dan bug di sistem
- **Audit**: Melihat riwayat aktivitas pemain
- **Deteksi Anomali**: Mendeteksi suspicious activity (misal: brute-force gate access dari IP yang sama)
- **Monitoring**: Melihat distribusi event secara real-time via dashboard

---

## 2. Arsitektur Sistem

```
┌──────────────────┐     ┌──────────┐     ┌──────────┐     ┌───────────────┐     ┌───────────────┐
│  Linked VERSE    │────▶│   Log    │────▶│ Filebeat │────▶│   Logstash    │────▶│ Elasticsearch │
│  App (Node.js)   │     │   File   │     │          │     │  (Filter &    │     │               │
│  Port 3000       │     │  .log    │     │          │     │   Route)      │     │               │
└──────────────────┘     └──────────┘     └──────────┘     └───────────────┘     └───────┬───────┘
                                                                                        │
                                                                                        ▼
                                                                                 ┌──────────────┐
                                                                                 │    Kibana     │
                                                                                 │  Port 5601   │
                                                                                 │  (Dashboard) │
                                                                                 └──────────────┘
```

**Alur Data:**
1. **Linked VERSE App** (Node.js/Express) menerima request dari pemain dan menulis log JSON ke file `logs/linked-verse.log`
2. **Filebeat** memantau file log secara real-time dan mengirim setiap baris ke Logstash
3. **Logstash** menerima log, mem-parse JSON, memvalidasi field wajib, menambah tag (`suspicious_activity`, `challenge_failed`, `missing_required_fields`), dan merutekan ke index yang tepat
4. **Elasticsearch** menyimpan log ke dalam 2 index:
   - `linked-verse-logs-YYYY.MM.DD` → log yang valid
   - `linked-verse-errors-YYYY.MM.DD` → log malformed / field hilang
5. **Kibana** menampilkan visualisasi dashboard interaktif

---

## 3. Penjelasan Setiap File

### 📄 `docker-compose.yml` — Konfigurasi Container

Mendefinisikan 5 service Docker:

| Service | Image | Port | Fungsi |
|---------|-------|------|--------|
| `elasticsearch` | elasticsearch:8.11.0 | 9200 | Database log, mode single-node, volume persisten `es_data` |
| `logstash` | logstash:8.11.0 | 5044 | Menerima log dari Filebeat, filter & route ke Elasticsearch |
| `filebeat` | filebeat:8.11.0 | — | Membaca file log, kirim ke Logstash |
| `kibana` | kibana:8.11.0 | 5601 | Dashboard visualisasi |
| `linked-verse` | custom (build) | 3000 | Aplikasi target yang menghasilkan log |

Semua service terhubung dalam satu network: `linked-verse-network`.

---

### 📄 `filebeat/filebeat.yml` — Konfigurasi Filebeat

```yaml
filebeat.inputs:
  - type: filestream          # Tipe input: filestream (baca file)
    id: linked-verse-log
    paths:
      - /logs/linked-verse.log  # File yang dipantau

output.logstash:
  hosts: ["logstash:5044"]    # Kirim ke Logstash port 5044
```

**Penjelasan:**
- Menggunakan input `filestream` untuk membaca file log
- Hanya memantau satu file: `/logs/linked-verse.log`
- Output dikirim ke Logstash pada host `logstash:5044`

---

### 📄 `logstash/logstash.conf` — Pipeline Logstash

**Input:** Menerima dari Filebeat via beats protocol (port 5044)

**Filter:**
1. Parse field `message` sebagai JSON
2. Validasi 8 field wajib: `level`, `service`, `player_id`, `player_name`, `event_type`, `linked_gate`, `status`, `message`
3. Jika field wajib hilang → tag `missing_required_fields`
4. Jika `event_type == "Invalid Gate Request"` → tag `suspicious_activity`
5. Jika `event_type == "Challenge Failed"` → tag `challenge_failed`

**Output:**
- Log malformed JSON atau field wajib hilang → index `linked-verse-errors-YYYY.MM.DD`
- Log valid → index `linked-verse-logs-YYYY.MM.DD`

---

### 📄 `scripts/generate-test-events.sh` — Script Simulasi

Mengirim **35 request** ke aplikasi untuk menghasilkan semua jenis event:

| Jenis Event | Jumlah | Keterangan |
|-------------|--------|------------|
| Gate Access Success | 7 | Akses gate berhasil |
| Gate Unlock Failed | 3 | Gagal buka kunci gate |
| Gate Unlock Success | 2 | Berhasil buka kunci gate |
| Challenge Start | 6 | Mulai challenge |
| Challenge Clear | 5 | Challenge berhasil |
| Challenge Failed | 4 | Challenge gagal |
| Invalid Gate Request | 6 | 4 dari IP yang sama (suspicious) |
| Malformed Log | 1 | JSON rusak |
| Missing Field Log | 1 | Field player_id & player_name hilang |

---

### 📄 `kibana/linked-verse-dashboard.ndjson` — Dashboard Export

Berisi 4 panel visualisasi + 1 data view:

| # | Panel | Tipe | Fungsi |
|---|-------|------|--------|
| 1 | Distribusi Log by Event Type | Pie Chart | Proporsi setiap jenis event |
| 2 | Tabel Suspicious Activity | Table | Event dengan tag `suspicious_activity` |
| 3 | Invalid Gate Request by Source IP | Table | Jumlah request invalid per IP |
| 4 | Challenge Failed by Gate & Player | Table | Pemain yang gagal challenge |

---

## 4. Langkah-Langkah Demo (Urutan Rekaman)

> ⚠️ **Sebelum mulai record**, pastikan **Docker Desktop sudah berjalan** dan tidak ada container lama yang running. Jika ada, jalankan `docker compose down` terlebih dahulu.

---

### BAGIAN A: Persiapan & Menjalankan Sistem

#### Langkah 1 — Tunjukkan Struktur Folder

```bash
cd project-logs-C01
ls -la
```

**Narasi:**
> "Ini adalah struktur folder proyek Linked VERSE Logs. Terdapat docker-compose.yml, folder filebeat, kibana, linked-verse (aplikasi), logstash, logs, dan scripts. Semua sesuai dengan ketentuan soal."

---

#### Langkah 2 — Jalankan Docker Compose

```bash
docker compose up -d
```

**Narasi:**
> "Kita jalankan semua service menggunakan docker compose up -d. Ini akan menjalankan 5 container: Elasticsearch, Logstash, Filebeat, Kibana, dan aplikasi Linked VERSE."

---

#### Langkah 3 — Cek Status Container

```bash
docker compose ps
```

Tunggu sampai Elasticsearch menunjukkan status `(healthy)`. Biasanya sekitar 1-2 menit.

**Narasi:**
> "Kita tunggu sampai Elasticsearch berstatus healthy. Sekarang semua 5 container sudah running."

---

### BAGIAN B: Verifikasi Aplikasi

#### Langkah 4 — Cek Health Check

Buka browser ke **http://localhost:3000/health** atau jalankan:

```bash
curl http://localhost:3000/health
```

Atau di PowerShell:
```powershell
curl.exe -s http://localhost:3000/health
```

**Hasil yang diharapkan:**
```json
{"status":"ok","service":"linked-verse-api"}
```

**Narasi:**
> "Aplikasi Linked VERSE berhasil berjalan di port 3000. Health check menunjukkan status OK."

---

### BAGIAN C: Generate Test Events

#### Langkah 5 — Jalankan Script Test Events

```bash
bash scripts/generate-test-events.sh
```

**Narasi:**
> "Sekarang kita jalankan script generate-test-events.sh yang akan mengirimkan 35 request ke aplikasi. Script ini menghasilkan semua jenis event yang diminta: Gate Access Success, Gate Unlock Failed, Challenge Start, Challenge Clear, Challenge Failed, Invalid Gate Request, serta log malformed dan log dengan field yang hilang."

---

#### Langkah 6 — Tunjukkan File Log

```bash
cat logs/linked-verse.log | head -5
wc -l logs/linked-verse.log
```

Atau di PowerShell:
```powershell
Get-Content .\logs\linked-verse.log | Select-Object -First 5
(Get-Content .\logs\linked-verse.log | Measure-Object -Line).Lines
```

**Narasi:**
> "File log sudah terisi dengan 35 baris JSON. Setiap baris berisi informasi seperti timestamp, player_id, player_name, event_type, status, dan lain-lain."

---

### BAGIAN D: Verifikasi Elasticsearch

#### Langkah 7 — Cek Index di Elasticsearch

Tunggu ±15-30 detik agar pipeline memproses, lalu:

```bash
curl -s "http://localhost:9200/_cat/indices?v"
```

Atau di PowerShell:
```powershell
curl.exe -s "http://localhost:9200/_cat/indices?v"
```

**Hasil yang diharapkan:** 2 index muncul:
- `linked-verse-logs-2026.05.XX` — berisi **33 dokumen** (log valid)
- `linked-verse-errors-2026.05.XX` — berisi **2 dokumen** (1 malformed + 1 missing field)

**Narasi:**
> "Di Elasticsearch, log sudah terpisah ke 2 index. Index linked-verse-logs berisi 33 log yang valid, dan index linked-verse-errors berisi 2 log error — satu malformed JSON dan satu yang field-nya hilang. Ini membuktikan bahwa Logstash berhasil memvalidasi dan merutekan log sesuai konfigurasi."

---

#### Langkah 8 — Hitung Jumlah Dokumen (Opsional)

```bash
curl -s "http://localhost:9200/linked-verse-logs-*/_count"
curl -s "http://localhost:9200/linked-verse-errors-*/_count"
```

Atau di PowerShell:
```powershell
curl.exe -s "http://localhost:9200/linked-verse-logs-*/_count"
curl.exe -s "http://localhost:9200/linked-verse-errors-*/_count"
```

---

### BAGIAN E: Kibana Dashboard

#### Langkah 9 — Buka Kibana

Buka browser ke **http://localhost:5601**

**Narasi:**
> "Sekarang kita buka Kibana di port 5601 untuk melihat visualisasi log."

---

#### Langkah 10 — Import Dashboard

1. Klik menu hamburger (☰) di kiri atas
2. Scroll ke bawah, klik **Stack Management**
3. Klik **Saved Objects**
4. Klik tombol **Import** (pojok kanan atas)
5. Upload file `kibana/linked-verse-dashboard.ndjson`
6. Klik **Import** untuk konfirmasi

**Narasi:**
> "Kita import dashboard yang sudah disiapkan. File ndjson ini berisi data view dengan index pattern linked-verse-*, 4 visualisasi, dan 1 dashboard."

---

#### Langkah 11 — Buka Dashboard

1. Klik menu hamburger (☰) → **Analytics** → **Dashboards**
2. Klik **Linked VERSE Dashboard**
3. Pastikan time range di pojok kanan atas = **Last 24 hours** atau **Today**

**Narasi (jelaskan setiap panel):**

> "Ini adalah Linked VERSE Dashboard dengan 4 panel:"
>
> "**Panel 1 — Distribusi Log by Event Type**: Pie chart yang menunjukkan proporsi setiap jenis event. Terlihat Gate Access Success dan Invalid Gate Request mendominasi."
>
> "**Panel 2 — Tabel Suspicious Activity**: Menampilkan event yang ditag suspicious_activity. Terlihat IP 192.168.66.6 dari player P9999 (SuspectX) yang mencoba mengakses gate tidak valid seperti EXPLOIT_GATE, HACKED_GATE, dan lainnya."
>
> "**Panel 3 — Invalid Gate Request by Source IP**: Menunjukkan jumlah Invalid Gate Request berdasarkan source IP. IP 192.168.66.6 memiliki jumlah tertinggi, mengindikasikan suspicious activity."
>
> "**Panel 4 — Challenge Failed by Gate & Player**: Menampilkan pemain yang gagal challenge. Player P0001 Sakura gagal di gate VERSE dan PARADISE, P0003 Miku gagal di UNIVERSE, dan P0002 Haruka gagal di X-VERSE."

---

#### Langkah 12 — Demo Filter KQL

Di search bar KQL di atas dashboard, ketik:

```
player_id: "P0001"
```

Lalu tekan Enter.

**Narasi:**
> "Kita juga bisa memfilter data menggunakan KQL atau Kibana Query Language. Misalnya, jika kita ketik player_id P0001, dashboard akan menampilkan hanya aktivitas dari player Sakura."

Hapus filter (klik X atau hapus teks), lalu coba:

```
tags: suspicious_activity
```

**Narasi:**
> "Atau kita bisa filter berdasarkan tag suspicious_activity untuk melihat hanya event yang mencurigakan."

---

### BAGIAN F: Uji Persistensi Data

#### Langkah 13 — Matikan Semua Container

```bash
docker compose down
```

**Narasi:**
> "Sekarang kita buktikan bahwa data bersifat persisten. Kita matikan seluruh service dengan docker compose down."

---

#### Langkah 14 — Nyalakan Kembali

```bash
docker compose up -d
```

Tunggu sampai healthy (±1-2 menit):

```bash
docker compose ps
```

**Narasi:**
> "Setelah docker compose down, semua container dihapus. Sekarang kita jalankan kembali dengan docker compose up -d dan tunggu sampai Elasticsearch healthy."

---

#### Langkah 15 — Verifikasi Data Masih Ada

```bash
curl -s "http://localhost:9200/_cat/indices?v"
```

Lalu buka Kibana di **http://localhost:5601** → **Dashboards** → **Linked VERSE Dashboard**

**Narasi:**
> "Bisa kita lihat, index linked-verse-logs dan linked-verse-errors masih ada di Elasticsearch. Dashboard di Kibana juga masih menampilkan semua data. Ini membuktikan bahwa data tersimpan secara persisten berkat konfigurasi Docker Volume pada Elasticsearch."

---

## 5. Ringkasan Poin Penilaian

| # | Poin yang Harus Dibuktikan | Cara Membuktikan |
|---|---------------------------|------------------|
| 1 | Struktur folder sesuai soal | `ls` / tampilkan di terminal |
| 2 | 5 container running | `docker compose ps` |
| 3 | App berjalan di port 3000 | `curl localhost:3000/health` |
| 4 | Script menghasilkan ≥30 log | Jalankan script, hitung baris log |
| 5 | Semua 6 jenis event + malformed + missing | Output script menampilkan summary |
| 6 | ≥3 suspicious dari IP sama | Output script + Kibana tabel |
| 7 | Log valid → `linked-verse-logs-*` | `curl localhost:9200/_cat/indices?v` |
| 8 | Log error → `linked-verse-errors-*` | `curl localhost:9200/_cat/indices?v` |
| 9 | Dashboard 4 panel berfungsi | Buka Kibana → Dashboard |
| 10 | KQL filter berfungsi | Ketik `player_id: "P0001"` |
| 11 | Data persisten setelah restart | `docker compose down` → `up -d` → cek lagi |

---

## 6. Tips Rekaman Video

- ⏱️ **Estimasi durasi**: 8-12 menit
- 🖥️ **Resolusi**: Gunakan resolusi layar yang jelas (1080p)
- 🎙️ **Narasi**: Jelaskan setiap langkah dengan suara yang jelas
- ⏳ **Saat menunggu Elasticsearch**: Jelaskan arsitektur/konfigurasi sambil menunggu
- 📋 **Urutan**: Struktur folder → Docker up → Health check → Generate events → Elasticsearch → Kibana import → Dashboard → KQL → Persistensi
- 🔄 **Jika ada error**: Pastikan Docker Desktop running dan tidak ada container lama
