# Linked VERSE Logs - Centralized Logging (ELK Stack)

Proyek ini merupakan implementasi Centralized Logging menggunakan ELK Stack (Elasticsearch, Logstash, Kibana) dan Filebeat untuk mencatat aktivitas pemain pada event Linked VERSE - CHUNITHM X-VERSE.

Proyek ini dibuat untuk memenuhi tugas **Soal Praktikum Modul 4 - Logging dan Monitoring (Soal 2)**.

## 🏗️ Arsitektur Sistem

Alur kerja (pipeline) logging pada proyek ini:
1. **Linked VERSE App** (Node.js) menulis log kejadian ke file `logs/linked-verse.log`.
2. **Filebeat** memantau file log tersebut secara real-time.
3. Filebeat mengirimkan setiap baris log ke **Logstash** (port 5044).
4. **Logstash** memproses (parse JSON), memvalidasi, memberi tag (seperti `suspicious_activity`, `challenge_failed`), dan merutekan log.
5. Logstash menyimpan hasil pemrosesan ke **Elasticsearch**.
   - Log yang valid masuk ke index `linked-verse-logs-YYYY.MM.DD`.
   - Log dengan error (malformed JSON/field hilang) masuk ke index `linked-verse-errors-YYYY.MM.DD`.
6. **Kibana** digunakan untuk memvisualisasikan data dari Elasticsearch ke dalam bentuk dashboard interaktif.

## 📁 Struktur Direktori

```text
project-logs-C01/
├── docker-compose.yml             # Konfigurasi container Docker
├── filebeat/
│   └── filebeat.yml               # Konfigurasi input filestream dan output ke Logstash
├── kibana/
│   └── linked-verse-dashboard.ndjson # File export Dashboard Kibana
├── linked-verse/                  # Source code aplikasi target (Linked VERSE App)
├── logs/
│   └── linked-verse.log           # File log aplikasi (dibuat otomatis)
├── logstash/
│   └── logstash.conf              # Pipeline Logstash (input, filter, output)
└── scripts/
    └── generate-test-events.sh    # Script untuk men-generate aktivitas simulasi log
```

## 🚀 Prasyarat

Pastikan perangkat Anda sudah terinstal:
- Docker
- Docker Compose

## 🛠️ Cara Menjalankan Proyek

1. Masuk ke direktori proyek:
   ```bash
   cd project-logs-C01
   ```

2. Jalankan semua service di latar belakang menggunakan Docker Compose:
   ```bash
   docker compose up -d
   ```

3. Pastikan semua service berjalan dan berstatus healthy:
   ```bash
   docker compose ps
   ```
   *Tunggu sekitar 1-2 menit hingga Elasticsearch berstatus `(healthy)`.*

## 🧪 Panduan Pengujian (Testing)

### 1. Membangkitkan Data Simulasi Log
Aplikasi berjalan pada port `3000`. Kita dapat membuat aktivitas log dengan menjalankan script yang telah disediakan.

- Jalankan script pengujian:
  ```bash
  bash scripts/generate-test-events.sh
  ```
- Script ini akan mengirimkan **35 request** ke aplikasi `linked-verse` dan men-generate berbagai kejadian (Gate Access, Challenge Clear, Suspicious Activity, dll).
- Anda dapat mengecek log mentahnya melalui:
  ```bash
  cat logs/linked-verse.log
  ```

### 2. Memverifikasi Rute Index di Elasticsearch
Setelah data digenerate, verifikasi apakah Logstash berhasil mengirimkan dan memisahkan log ke Elasticsearch.

- Cek daftar index:
  ```bash
  curl -s "http://localhost:9200/_cat/indices?v"
  ```
  *Anda akan melihat index `linked-verse-logs-*` dan `linked-verse-errors-*`.*

- Menghitung jumlah log yang masuk:
  ```bash
  # Total log valid (seharusnya 33 dokumen)
  curl -s "http://localhost:9200/linked-verse-logs-*/_count"

  # Total log error/malformed (seharusnya 2 dokumen)
  curl -s "http://localhost:9200/linked-verse-errors-*/_count"
  ```

### 3. Import & Memeriksa Dashboard di Kibana
Buka browser dan akses Kibana di **`http://localhost:5601`**.

1. Buka menu **Stack Management > Saved Objects**.
2. Klik **Import** di pojok kanan atas.
3. Upload file `kibana/linked-verse-dashboard.ndjson`.
4. Buka tab **Dashboards** dan pilih **Linked VERSE Dashboard**.
5. Ganti rentang waktu (Time Filter) di pojok kanan atas menjadi **Today** atau **Last 24 hours**.

Pada Dashboard ini, Anda akan melihat 4 Panel:
- **Distribusi Log by Event Type** (Pie Chart)
- **Tabel Suspicious Activity** (Menampilkan IP `192.168.66.6` dan event yang ditag `suspicious_activity`)
- **Invalid Gate Request by Source IP** (Bar Chart)
- **Challenge Failed by Gate & Player** (Tabel pemain yang gagal challenge)

### 4. Uji Filter KQL di Kibana
Untuk mencari aktivitas pemain spesifik, gunakan search bar KQL (Kibana Query Language) di atas dashboard:
- Ketik: `player_id: "P0001"` lalu tekan Enter.
- Ketik: `tags: suspicious_activity` lalu tekan Enter.

### 5. Uji Persistensi Data (Restart Simulasi)
Log harus tetap tersimpan meskipun server dimatikan. Buktikan dengan:

1. Matikan semua container:
   ```bash
   docker compose down
   ```
2. Nyalakan kembali:
   ```bash
   docker compose up -d
   ```
3. Tunggu hingga service healthy, lalu cek kembali di Kibana atau Elasticsearch. Data log dan dashboard tidak akan hilang karena sudah menggunakan konfigurasi Docker Volume.
