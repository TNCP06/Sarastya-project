# ProjekTask — Aplikasi Manajemen Project & Task

> Project-Based Test — Magang Fullstack Developer, Sarastya Agility Innovations
> Oleh: **Tionusa Catur Pamungkas** — D4 Teknik Informatika, Politeknik Negeri Malang

**Status: ✅ Selesai — seluruh komponen sudah di-deploy dan dapat diakses publik.**
Repositori ini adalah halaman utama proyek. Kode tiap komponen berada di repositori terpisah (tautan di bawah).

---

## Tentang Aplikasi

ProjekTask adalah aplikasi manajemen project dan task sederhana. Setiap pengguna dapat mendaftar, membuat project, lalu mengelola task di dalam tiap project (membuat, mengubah status *todo → in progress → done*, dan menghapus). Aplikasi terdiri dari satu backend API yang dikonsumsi oleh dua frontend: web dan mobile.

## Arsitektur

```
┌─────────────────┐      ┌──────────────────┐
│  Web (Next.js)  │──┐   │ Mobile (Flutter) │
│   @ Vercel      │  │   │     (APK)        │
└─────────────────┘  │   └────────┬─────────┘
                     │            │
                     ▼            ▼
            ┌─────────────────────────┐
            │  REST API (ASP.NET 8)   │
            │  JWT Auth · Swagger     │
            │     @ AWS EC2           │
            └────────────┬────────────┘
                         ▼
                 ┌──────────────┐
                 │  PostgreSQL  │
                 └──────────────┘
```

- **Backend** — ASP.NET Core 8 (arsitektur berlapis), PostgreSQL. Operasi baca menggunakan raw SQL (Dapper), operasi tulis menggunakan Entity Framework Core. Autentikasi JWT, validasi FluentValidation, logging Serilog, global exception handling, dokumentasi Swagger. Di-deploy di AWS EC2.
- **Frontend Web** — React via Next.js, state management Zustand, Fetch API, desain responsif (desktop & tablet). Panggilan ke API diteruskan lewat proxy sisi server (Next.js rewrites) untuk mengatasi mixed content HTTPS→HTTP.
- **Frontend Mobile** — Flutter, state management Provider, HTTP client Dio dengan interceptor JWT, token disimpan di secure storage, build APK Android.

## Repositori Komponen

| Komponen | Repositori | Deploy |
|---|---|---|
| 🔧 Backend API | [Sarastya-project-api](https://github.com/TNCP06/Sarastya-project-api) | ✅ AWS EC2 |
| 🌐 Frontend Web | [Sarastya-project-web](https://github.com/TNCP06/Sarastya-project-web) | ✅ Vercel |
| 📱 Frontend Mobile | [Sarastya-project-mobile](https://github.com/TNCP06/Sarastya-project-mobile) | ✅ APK (GitHub Release) |

Petunjuk setup, cara menjalankan secara lokal, dan instruksi deployment tersedia di README masing-masing repositori.

## Tautan Hasil

- 🌐 **Aplikasi Web:** https://sarastya-project-web.vercel.app/
- 🔧 **API + Swagger:** http://18.143.171.142:8080/swagger
- 📱 **Download APK:** https://github.com/TNCP06/Sarastya-project-mobile/releases/latest

## Dokumen Perencanaan

- [Kontrak API](https://github.com/TNCP06/Sarastya-project-api/blob/main/kontrak-api-projektask.md) — spesifikasi endpoint, bentuk data, format error, dan skema database yang menjadi acuan ketiga komponen.

## Teknologi Utama

`ASP.NET Core 8` · `PostgreSQL` · `Dapper` · `Entity Framework Core` · `JWT` · `Serilog` · `Swagger` · `Next.js` · `Zustand` · `Tailwind CSS` · `Flutter` · `Provider` · `Dio` · `Git (Conventional Commits)`