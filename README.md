# Kolekcionāru katalogs

Web lietojumprogramma kolekcionāriem, kas ļauj reģistrēt, sakārtot un pārvaldīt savas kolekcijas, kā arī sekot līdzi priekšmetu informācijai un stāvoklim.

## Funkcijas

- Lietotāju reģistrācija un autorizācija
- Kolekcijas priekšmetu pievienošana, rediģēšana un dzēšana
- Meklēšana un filtrēšana pēc kategorijām un parametriem
- Attēlu pievienošana priekšmetiem
- Lietotāja skats un kolekcijas pārvaldība

## Tehnoloģiju steks

- **Backend:** PHP / Laravel
- **Frontend:** Vue.js / Vite
- **Datubāze:** MySQL
- **Rīki:** Git, npm, Composer

## Datubāze

Datubāzes shēma atrodas failā [`datubaze.sql`](datubaze.sql).

Galvenās tabulas: `lietotāji`, `prece`, `kategorijas` un citas ar kolekciju pārvaldību saistītas tabulas.

## Projekta struktūra

```
backend/      Laravel backend (maršruti, kontrolieri, modeļi)
frontend/     Lietojumprogrammas priekšējā daļa
datubaze.sql  Datubāzes shēma
```

## Darba sākšana

Prasības: PHP, Composer, Node.js, MySQL.

```bash
git clone https://github.com/DP3PFome/proektdarbs.git
cd proektdarbs

# Datubāze
# Izveido tukšu datubāzi un importē datubaze.sql

# Backend
cd backend
composer install
# Windows CMD: if not exist .env copy .env.example .env
# macOS/Linux: cp .env.example .env
# Ja .env jau eksistē, nepārrakstiet to; pārliecinieties, ka tajā ir APP_KEY=
php artisan key:generate
php artisan serve

# Frontend (jaunā terminālī)
cd frontend
npm install
npm run dev
```

Lietojumprogramma būs pieejama šeit: `http://localhost:5173`.

## Par šo projektu

Studiju projekts, kas izveidots, lai praktizētu datubāzu projektēšanu, SQL un pilna steka tīmekļa izstrādi.

- Es izstrādāju datubāzes struktūru un galvenās funkcijas.
- Es izmantoju AI rīkus (piemēram, Claude, Cursor), lai paātrinātu koda rakstīšanu, pēc tam pats pārskatīju, testēju un atkļūdoju rezultātu.
- Projekta dokumentācija latviešu valodā atrodas failā `projekta_dokumentacija_kolekcionariem.docx`.

## Autors

Platons Fomenko, [GitHub](https://github.com/DP3PFome)