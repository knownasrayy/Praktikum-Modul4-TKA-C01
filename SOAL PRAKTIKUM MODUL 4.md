**Soal Praktikum Modul 4**  
**Logging dan Monitoring**

1. Waktu pengerjaan praktikum sesuai dengan timeline yang diberikan (**Senin, 11 May 2026  jam 10.00 WIB sampai Sabtu, 16 Mei 2026 jam 23.59 WIB**).  
2. Hasil pengerjaan praktikum dalam bentuk video demonstrasi diupload ke Youtube dalam 1 playlist berjudul **\[Kelompok\] \- TKA 2026** (Contoh: E03 \- TKA 2026\) dengan status **unlisted** dan format judul video **TKA\_\[Kelompok\]\_Modul X \[Judul Modul\]** (Contoh: TKA\_E03\_Modul 4 Logging & Monitoring)  
3. Praktikan tidak diperbolehkan menanyakan jawaban dari soal yang diberikan kepada asisten maupun praktikan dari kelompok lainnya.  
4. Pengerjaan soal sesuai dengan modul yang telah diajarkan.  
5. Jika ditemukan indikasi kecurangan dalam bentuk apapun di pengerjaan soal shift, maka nilai dianggap 0\.  
6. Pengumpulan video demonstrasi dikumpulkan melalui Google Form pada link berikut: [its.id/m/PengumpulanTKA2026](http://its.id/m/PengumpulanTKA2026)  
7. Harap mengumpulkan tepat waktu karena apabila lebih dari waktu yang ditentukan akan mendapat **pengurangan nilai sebanyak 5% per jam** dari hasil nilai yang diperoleh.

2. **Linked VERSE Logs**

Dalam event Linked VERSE pada CHUNITHM X-VERSE, pemain membuka akses ke berbagai Linked GATE berdasarkan episode atau versi CHUNITHM tertentu. Linked VERSE sendiri merupakan sistem unlock khusus yang ditambahkan pada CHUNITHM X-VERSE sebagai event besar bertema perjalanan ulang berbagai versi CHUNITHM sebelumnya.

Pada sistem ini, setiap gate memiliki kondisi akses tertentu. Setelah kondisi terpenuhi, pemain dapat masuk ke mode Linked VERSE dan menjalankan challenge. Challenge juga berkaitan dengan matching dan clear condition, sehingga event log seperti akses gate, status unlock, hasil challenge, dan error sistem perlu dicatat dengan baik.


Dalam study case ini, kalian diminta membangun sistem centralized logging menggunakan ELK Stack untuk mencatat aktivitas pemain saat mengakses fitur Linked VERSE. Pada modul ini, logging digunakan untuk mencatat kejadian sistem, membantu troubleshooting, audit, serta mendeteksi aktivitas tidak normal.

1. Siapkan struktur folder proyek kedua kalian persis seperti berikut:   
   project-logs-\[Kelompok\]/  
   ├── docker-compose.yml  
   ├── filebeat  
   │   └── filebeat.yml  
   ├── kibana  
   │   └── linked-verse-dashboard.ndjson  
   ├── linked-verse  
   │   ├── app.js  
   │   ├── Dockerfile  
   │   ├── logger.js  
   │   └── package.json  
   ├── logs  
   │   └── linked-verse.log (dibuat otomatis)  
   ├── logstash  
   │   └── logstash.conf  
   └── scripts  
       └── generate-test-events.sh  
     
2. Gunakan **linked-verse/** dari repository yang disediakan: [\[Linked VERSE App\]](https://files.catbox.moe/fjlii0.zip) (mff kalo vibecoding asisten malas). **logs/linked-verse.log** akan dibuat otomatis oleh aplikasi saat endpoint dipanggil.  
     
3. Buatlah file **docker-compose.yml** untuk sistem centralized logging dengan ketentuan berikut:  
   1. Network  
      1. Semua service berada di network yang sama.  
   2. Elasticsearch  
      1. Gunakan image docker.elastic.co/elasticsearch/elasticsearch:8.11.0  
      2. Elasticsearch dijalankan dalam mode single-node.  
      3. Data Elasticsearch dibuat persisten menggunakan volume.  
   3. Logstash  
      1. Gunakan image docker.elastic.co/logstash/logstash:8.11.0  
      2. Logstash menerima log dari Filebeat melalui input beats pada port 5044\.  
   4. Filebeat  
      1. Gunakan image docker.elastic.co/beats/filebeat:8.11.0.  
      2. Filebeat membaca file log dari folder logs/.  
      3. Filebeat mengirim log ke Logstash.  
   5. Kibana  
      1. Gunakan image docker.elastic.co/kibana/kibana:8.11.0  
      2. Kibana digunakan untuk membuat data view, discover, dan dashboard log.  
           
4. Buat file **scripts/generate-test-events.sh** dengan ketentuan berikut:  
   1. Script ini digunakan untuk mengirim request ke **linked-verse/**.  
   2. Script harus menghasilkan minimal 30 log JSON di **logs/linked-verse.log** setelah dijalankan.  
   3. Script wajib menghasilkan seluruh jenis event berikut:  
      1. Gate Access Success  
      2. Gate Unlock Failed  
      3. Challenge Start  
      4. Challenge Clear  
      5. Challenge Failed  
      6. Invalid Gate Request  
   4. Script wajib menghasilkan minimal 3 event **Invalid Gate Request** dari **source\_ip** yang sama untuk mensimulasikan suspicious activity.  
   5. Script wajib memanggil endpoint **POST /debug/malformed-log** minimal satu kali.  
   6. Script wajib memanggil endpoint **POST /debug/missing-field-log** minimal satu kali.  
        
5. Buat file **filebeat/filebeat.yml** dengan ketentuan berikut:   
   1. Gunakan input filestream.  
   2. Baca hanya file /logs/linked-verse.log.  
   3. Kirim output ke Logstash pada host logstash:5044.  
        
6. Buat file **logstash/logstash.conf** dengan ketentuan berikut:  
   1. Gunakan input beats.  
   2. Parse field message sebagai JSON.  
   3. Validasi field wajib: level, service, player\_id, player\_name, event\_type, linked\_gate, status, message.  
   4. Jika ada field wajib yang hilang, tambahkan tag missing\_required\_fields.  
   5. Jika event\_type bernilai Invalid Gate Request, tambahkan tag suspicious\_activity.  
   6. Jika event\_type bernilai Challenge Failed, tambahkan tag challenge\_failed.  
   7. Jika log malformed JSON atau field wajib hilang, simpan ke index linked-verse-errors-\[tanggal\].  
   8. Jika log valid, simpan ke index linked-verse-logs-\[tanggal\].  
         
7. Kibana harus memenuhi ketentuan berikut:  
   1. Buat data view dengan index pattern **linked-verse-\*** dan time field **@timestamp**.  
   2. Import dashboard dari **kibana/linked-verse-dashboard.ndjson**.  
   3. Dashboard minimal memiliki:  
      1. Distribusi log berdasarkan **event\_type**.  
      2. Tabel suspicious activity.  
      3. Jumlah **Invalid Gate Request** berdasarkan **source\_ip**.  
      4. Tabel **Challenge Failed** berdasarkan **linked\_gate** dan **player\_id**.  
   4. Tunjukkan cara filter data berdasarkan player\_id menggunakan KQL, contoh:  
      1. player\_id: "P0001"

8. Jika konfigurasi berhasil, aplikasi Linked VERSE dapat diakses melalui browser pada **http://localhost:3000** dan health check dapat dilihat pada **http://localhost:3000/health**. Jalankan **scripts/generate-test-events.sh**, lalu buktikan bahwa log valid masuk ke index **linked-verse-logs-\*** dan log error atau malformed masuk ke index **linked-verse-errors-\***.  
     
9. Akses Kibana melalui **http://localhost:5601**, buat data view **linked-verse-\***, import dashboard, lalu tunjukkan visualisasi event Linked VERSE beserta filter player\_id. Buktikan juga bahwa data log tetap tersimpan secara persisten meskipun seluruh layanan dihentikan dan dijalankan kembali menggunakan docker compose down dan docker compose up \-d. Setelah layanan menyala kembali, tunjukkan bahwa index **linked-verse-logs-\*** dan **linked-verse-errors-\*** masih dapat dicari melalui Elasticsearch atau Kibana.  