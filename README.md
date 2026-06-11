# ProjekTask — Aplikasi Manajemen Project & Task

> Project-Based Test — Magang Fullstack Developer, Sarastya Agility Innovations
> Oleh: **Tionusa Catur Pamungkas** — D4 Teknik Informatika, Politeknik Negeri Malang

**Status: 🚧 Dalam pengembangan aktif — target selesai: 18 Juni 2026**
Repositori ini adalah halaman utama proyek. Kode tiap komponen berada di repositori terpisah (tautan di bawah) dan akan terus di-push selama periode pengerjaan.

---

## Tentang Aplikasi

ProjekTask adalah aplikasi manajemen project dan task sederhana. Setiap pengguna dapat mendaftar, membuat project, lalu mengelola task di dalam tiap project (membuat, mengubah status *todo → in progress → done*, dan menghapus). Aplikasi terdiri dari satu backend API yang dikonsumsi oleh dua frontend: web dan mobile.

## Arsitektur

```
┌─────────────────┐      ┌──────────────────┐
│  Web (Next.js)  │──┐   │ Mobile (Flutter) │
└─────────────────┘  │   └────────┬─────────┘
                     │            │
                     ▼            ▼
            ┌─────────────────────────┐
            │  REST API (ASP.NET 8)   │
            │  JWT Auth · Swagger     │
            └────────────┬────────────┘
                         ▼
                 ┌──────────────┐
                 │  PostgreSQL  │
                 └──────────────┘
```

- **Backend** — ASP.NET Core 8 (arsitektur berlapis 4 project), PostgreSQL. Operasi baca menggunakan raw SQL (Dapper), operasi tulis menggunakan Entity Framework Core. Autentikasi JWT, validasi FluentValidation, logging Serilog, global exception handling, dokumentasi Swagger.
- **Frontend Web** — React via Next.js, state management Zustand, Fetch API, desain responsif (desktop & tablet).
- **Frontend Mobile** — Flutter, state management Riverpod, HTTP client Dio, build APK Android.

## Repositori Komponen

| Komponen | Repositori | Deploy |
|---|---|---|
| 🔧 Backend API | [Sarastya-project-api](https://github.com/TNCP06/Sarastya-project-api) | 🔜 Render.com |
| 🌐 Frontend Web | [Sarastya-project-web](https://github.com/TNCP06/Sarastya-project-web) | 🔜 Vercel |
| 📱 Frontend Mobile | [Sarastya-project-mobile](https://github.com/TNCP06/Sarastya-project-mobile) | 🔜 APK (GitHub Release) |

Petunjuk setup, cara menjalankan secara lokal, dan instruksi deployment tersedia di README masing-masing repositori.

## Tautan Hasil (akan diisi saat deployment selesai)

- 🌐 Aplikasi Web: *menyusul*
- 🔧 API + Swagger: *menyusul*
- 📱 Download APK: *menyusul*
- 🎥 Video Presentasi: *menyusul*

## Dokumen Perencanaan

- [Kontrak API](https://github.com/TNCP06/Sarastya-project-api/blob/main/kontrak-api-projektask.md) — spesifikasi endpoint, bentuk data, format error, dan skema database yang menjadi acuan ketiga komponen.

## Teknologi Utama

`ASP.NET Core 8` · `PostgreSQL` · `Dapper` · `Entity Framework Core` · `JWT` · `Serilog` · `Swagger` · `Next.js` · `Zustand` · `Tailwind CSS` · `Flutter` · `Riverpod` · `Dio` · `GitHub Actions (Conventional Commits)`
