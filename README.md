# postgres-playground

Учебная площадка для изучения продвинутых возможностей PostgreSQL. Каждая демонстрация — изолированный пример с SQL-миграциями (up/down) и TypeScript-раннером, который выполняет запросы и выводит результат в консоль. Всё запускается через Docker Compose: контейнер с приложением, PostgreSQL с расширениями и pgAdmin.

Проект рассчитан на тех, кто уже знаком с основами SQL и хочет разобраться в продвинутых конструкциях PostgreSQL на практике.

## Стек технологий

- **PostgreSQL 17** — СУБД с расширениями pg_cron, pg_ivm, btree_gist
- **Node.js 22** (Alpine) — среда выполнения
- **TypeScript 5** — раннеры демонстраций
- **pg (node-postgres)** — драйвер PostgreSQL
- **Zod** — валидация переменных окружения
- **Prisma** — ORM (для миграций, опционально)
- **Docker Compose** — оркестрация контейнеров
- **pgAdmin 4** — веб-интерфейс управления БД
- **pnpm** — менеджер пакетов
- **tsx** — запуск TypeScript без компиляции

## Требования

- Docker и Docker Compose
- Node.js 22+ и pnpm (для локальной разработки вне контейнера, опционально)

## Быстрый старт

1. Клонировать репозиторий:

```bash
git clone <repo-url>
cd postgres-playground
```

2. Запустить все контейнеры:

```bash
docker-compose -f docker-compose.yml up -d
```

Docker поднимет три сервиса: `app`, `db` и `pgadmin`. Контейнер `app` стартует после того, как `db` пройдёт healthcheck. При первом запуске образ БД собирается из `db.Dockerfile` — устанавливаются расширения pg_cron и pg_ivm, а скрипты из `init-db/` инициализируют базу.

3. Запустить любую демонстрацию (например, оконные функции):

```bash
npm run d:7-window-functions
```

Команда подключится к контейнеру `app`, выполнит `up.sql` (создание таблиц), запустит `index.ts` (запросы), затем `down.sql` (очистка). Результаты выводятся в терминал.

4. Открыть pgAdmin по адресу http://localhost:5051 для визуального просмотра данных (если демонстрация не выполняет `down.sql` автоматически или вы хотите осмотреть структуры до очистки).

## Архитектура проекта

```
postgres-playground/
├── docker-compose.yml           # оркестрация: app + db + pgadmin
├── Dockerfile                   # образ приложения (Node.js 22 Alpine)
├── db.Dockerfile                # образ БД (PostgreSQL 17 + pg_cron + pg_ivm)
├── docker/
│   └── entrypoint.sh            # точка входа контейнера app
├── environments/
│   ├── .env.dev                 # NODE_ENV
│   └── .env.dev.pg              # параметры подключения к PostgreSQL и pgAdmin
├── init-db/
│   └── 003_main.sql             # инициализация расширений при первом запуске БД
├── schema.prisma                # схема Prisma (опциональная)
├── src/
│   ├── shared/
│   │   ├── pool.ts              # пул соединений (pg.Pool + pg.Client)
│   │   ├── run-command-in-terminal.ts  # утилита для запуска shell-команд
│   │   └── environments/
│   │       ├── env.general.ts   # валидация NODE_ENV через Zod
│   │       └── env.pg.ts        # валидация PG-переменных через Zod
│   └── playground/
│       ├── FEATURES/            # демонстрации возможностей PostgreSQL
│       │   ├── 1-ranking_and_view/
│       │   ├── 2-correlated-query/
│       │   ├── ...
│       │   └── 12-MV_with_trigger_and_notification/
│       └── INDEXES/             # демонстрации индексов
│           └── 1-exclusion-index/
├── package.json
├── tsconfig.json
└── todo.md                      # дорожная карта
```

Каждая демонстрация — отдельная директория с тремя файлами:

- `up.sql` (или `init.sql`) — создание таблиц, функций, триггеров, представлений
- `index.ts` — TypeScript-раннер, выполняющий запросы и выводящий результаты
- `down.sql` (или `drop.sql`) — очистка: удаление всех созданных объектов

Скрипт `init.sh` в каждой директории последовательно запускает `up.sql → index.ts → down.sql`.

## Конфигурация

### Docker-сервисы

| Сервис    | Контейнер                          | Порт         | Описание                              |
|-----------|------------------------------------|--------------|---------------------------------------|
| `app`     | `playground-pg-app_container`      | 3000:3000    | Node.js-приложение, выполняет раннеры |
| `db`      | `playground-pg-db_container`       | 5433:5432    | PostgreSQL 17 с расширениями          |
| `pgadmin` | `playground-pg-pgadmin4_container` | 5051:80      | Веб-интерфейс pgAdmin 4              |

Контейнер `app` монтирует корень проекта внутрь `/usr/src/app` (volume mapping), поэтому изменения в коде применяются без пересборки. Контейнер `db` использует именованный volume `playground-pg_data` для персистентности данных.

### Переменные окружения

**`environments/.env.dev`** — общие настройки:

| Переменная | Значение      | Описание               |
|------------|---------------|------------------------|
| `NODE_ENV` | `development` | Режим работы приложения |

**`environments/.env.dev.pg`** — настройки PostgreSQL и pgAdmin:

| Переменная              | Значение              | Описание                   |
|-------------------------|-----------------------|----------------------------|
| `POSTGRES_USER`         | `postgres`            | Имя пользователя БД       |
| `POSTGRES_PASSWORD`     | `midapa24`            | Пароль                     |
| `POSTGRES_HOST`         | `db`                  | Хост (имя сервиса в Docker)|
| `POSTGRES_DB`           | `postgres`            | Имя базы данных            |
| `POSTGRES_PORT`         | `5432`                | Порт внутри контейнера     |
| `PGADMIN_DEFAULT_EMAIL` | `pgadmin@example.com` | Email для входа в pgAdmin  |
| `PGADMIN_DEFAULT_PASSWORD` | `midapa24`         | Пароль для pgAdmin         |

## Справочник npm-скриптов

### Управление контейнерами

| Команда               | Описание                                                             |
|-----------------------|----------------------------------------------------------------------|
| `npm run d:up`        | Запуск всех контейнеров                                              |
| `npm run d:down`      | Остановка всех контейнеров                                           |
| `npm run d:restart`   | Перезапуск всех контейнеров                                          |
| `npm run d:restart-app` | Пересоздание только контейнера `app`                               |
| `npm run d:connect`   | Подключение к контейнеру `app` с выполнением команды                 |

### Работа с базой данных

| Команда                    | Описание                                                          |
|----------------------------|-------------------------------------------------------------------|
| `npm run d:drop-db`        | Полная очистка базы (DROP SCHEMA + CREATE SCHEMA)                 |
| `npm run d:rebuild-db`     | Пересборка контейнера БД с нуля (удаляет volume и образ)          |
| `npm run d:list-extensions`| Список установленных расширений PostgreSQL                        |

### Prisma-миграции

| Команда                    | Описание                                       |
|----------------------------|-------------------------------------------------|
| `npm run d:create-migration` | Создание новой миграции Prisma                |
| `npm run d:apply-migration`  | Применение миграции `0_init`                  |
| `npm run d:deploy`           | Деплой миграций Prisma                        |

### Очистка Docker-ресурсов

| Команда                        | Описание                                          |
|--------------------------------|---------------------------------------------------|
| `npm run d:clean:containers`   | Удаление всех контейнеров playground-pg-*         |
| `npm run d:clean:dangling-images`  | Удаление висячих Docker-образов               |
| `npm run d:clean:dangling-volumes` | Удаление висячих Docker-томов                 |
| `npm run d:clean:full`         | Полная очистка: контейнеры, образы, тома          |

### Запуск демонстраций

| Команда                                       | Демонстрация                             |
|-----------------------------------------------|------------------------------------------|
| `npm run d:1-ranking_and_view`                | Ранжирование и представления             |
| `npm run d:2-correlated-query`                | Коррелированные подзапросы               |
| `npm run d:3-CTE`                             | Common Table Expressions                 |
| `npm run d:4-RCTE`                            | Рекурсивные CTE                         |
| `npm run d:5-functions`                       | Пользовательские функции                 |
| `npm run d:6-procedures`                      | Хранимые процедуры                       |
| `npm run d:7-window-functions`                | Оконные функции                          |
| `npm run d:8-jsonb_with_MV_and_trigger`       | JSONB + материализованные представления  |
| `npm run d:9-pg-cron`                         | Планировщик pg_cron                      |
| `npm run d:10-full-text-search:1`             | Полнотекстовый поиск (базовый)           |
| `npm run d:10-full-text-search:2`             | Полнотекстовый поиск (продвинутый)       |
| `npm run d:11-fuzzy-search`                   | Нечёткий поиск                           |
| `npm run d:12-MV_with_trigger_and_notification:1` | MV + триггер + LISTEN/NOTIFY        |
| `npm run d:12-MV_with_trigger_and_notification:2` | MV + pg_ivm (инкрементальное обновление) |
| `npm run d:1-exclusion-index`                 | Exclusion-индекс                         |

## Каталог демонстраций

### 1. Ранжирование и представления

**Путь:** `src/playground/FEATURES/1-ranking_and_view/`

Построение цепочки представлений (VIEW) для анализа продаж. Первое представление `monthly_sales` агрегирует продажи по регионам и продавцам через `SUM() + GROUP BY`. Второе представление `ranked_sales` добавляет ранжирование внутри каждого региона с помощью `RANK() OVER (PARTITION BY region)`.

Ключевые конструкции: `CREATE VIEW`, `RANK()`, `OVER (PARTITION BY ... ORDER BY ...)`, `SUM()`, `GROUP BY`.

В результатах видно, как каждый продавец получает ранг относительно коллег в своём регионе — одинаковые суммы получают одинаковый ранг.

### 2. Коррелированные подзапросы

**Путь:** `src/playground/FEATURES/2-correlated-query/`

Поиск сотрудников, чья зарплата превышает среднюю по их отделу. Подзапрос выполняется для каждой строки внешнего запроса, обращаясь к текущему значению `department` — это и делает его коррелированным.

```sql
SELECT * FROM employees e
WHERE salary > (
  SELECT AVG(salary) FROM employees WHERE department = e.department
)
```

В результатах — по одному сотруднику из каждого отдела (те, кто зарабатывает выше среднего). Отдел с единственным сотрудником не попадает в выборку, поскольку средняя зарплата равна его собственной.

### 3. Common Table Expressions (CTE)

**Путь:** `src/playground/FEATURES/3-CTE/`

Решение той же задачи, что и в демонстрации 2 (сотрудники с зарплатой выше средней по отделу), но через CTE с конструкцией `WITH`. CTE выносит подзапрос с агрегацией в именованный блок, делая основной запрос нагляднее и проще для отладки.

### 4. Рекурсивные CTE

**Путь:** `src/playground/FEATURES/4-RCTE/`

Обход графа подписок для генерации рекомендаций «кого подписать». Таблица `followers` задаёт связи между пользователями. `WITH RECURSIVE` обходит цепочки подписок вглубь до 3 уровней, отслеживая глубину через столбец `depth`.

```sql
WITH RECURSIVE suggestions(leader_id, follower_id, depth) AS (
  SELECT leader_id, follower_id, 1 FROM followers WHERE follower_id = 10
  UNION ALL
  SELECT f.leader_id, f.follower_id, s.depth + 1
  FROM followers f JOIN suggestions s ON s.leader_id = f.follower_id
  WHERE s.depth < 3
)
```

На выходе — пользователи на глубине 2 и 3 (друзья друзей), которых можно предложить в качестве рекомендаций.

### 5. Пользовательские функции

**Путь:** `src/playground/FEATURES/5-functions/`

Две PL/pgSQL-функции с разными типами возвращаемых значений. `get_all_volumes(manga_id INT)` возвращает `TABLE` — набор строк из JOIN между `mangas` и `volumes`. `get_manga_from_price(price FLOAT)` возвращает `VARCHAR` — скалярное значение через `SELECT INTO`.

Ключевые конструкции: `CREATE FUNCTION ... RETURNS TABLE`, `RETURNS VARCHAR`, `RETURN QUERY SELECT`, `SELECT INTO`, `LANGUAGE plpgsql`.

### 6. Хранимые процедуры

**Путь:** `src/playground/FEATURES/6-procedures/`

Процедура `archive_old_orders()` перемещает заказы старше 2020 года из таблицы `orders` в `orders_archive`. Сначала вставляет в архив через `INSERT INTO ... SELECT`, затем удаляет перенесённые строки.

Вызов через `CALL archive_old_orders()`. В отличие от функций, процедуры не возвращают значение через `RETURN`, но могут управлять транзакциями.

### 7. Оконные функции

**Путь:** `src/playground/FEATURES/7-window-functions/`

Два примера оконных функций. Первый — `AVG(salary) OVER (PARTITION BY department)` для средней зарплаты по отделу без свёртки строк, плюс `RANK() OVER (ORDER BY salary DESC)` для глобального рейтинга.

Второй — работа с фреймами окна на примере `LAST_VALUE()`. По умолчанию фрейм охватывает строки от начала партиции до текущей строки (`RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`), из-за чего `LAST_VALUE()` возвращает значение текущей строки, а не последней в группе. Для получения максимальной цены в группе нужен расширенный фрейм: `RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING`.

Другие доступные оконные функции: `ROW_NUMBER()`, `DENSE_RANK()`, `FIRST_VALUE()`, `NTH_VALUE()`, `LAG()`, `LEAD()`.

### 8. JSONB + материализованные представления + триггеры

**Путь:** `src/playground/FEATURES/8-jsonb_with_MV_and_trigger/`

Работа с JSONB-столбцами: хранение атрибутов товаров и строк заказа в JSON-формате. GIN-индексы на JSONB-столбцах обеспечивают производительность запросов.

Материализованное представление `product_specs` извлекает данные из JSONB через операторы `->>`, `#>>`, `->` и функцию `jsonb_path_query_array()`. Триггер автоматически обновляет MV при изменении базовой таблицы.

Функция `total_category_sales()` разворачивает JSONB-массив через `jsonb_array_elements()` и агрегирует продажи по категориям.

Ключевые JSONB-операторы:

| Оператор | Назначение                         | Пример                                  |
|----------|------------------------------------|-----------------------------------------|
| `->`     | Доступ к объекту/элементу массива  | `attributes->'dimensions'`              |
| `->>`    | Извлечение как текст               | `attributes->>'brand'`                  |
| `#>>`    | Извлечение по пути как текст       | `attributes#>>'{weight,value}'`         |
| `@>`     | Проверка вхождения                 | `line_items @> '[{"options": {...}}]'`  |

### 9. Планировщик pg_cron

**Путь:** `src/playground/FEATURES/9-pg-cron/`

ETL-задача, запускаемая по расписанию. Процедура `etl_job()` берёт одну строку из `staging_data`, трансформирует (приведение текста к верхнему регистру через `UPPER()`) и переносит в `production_data`. Задача запланирована через `cron.schedule()` с интервалом 5 секунд.

```sql
SELECT cron.schedule('etl_job_schedule', '5 seconds', 'CALL etl_job()');
```

Раннер выводит содержимое обеих таблиц, ждёт 10 секунд и показывает результат — данные переместились из staging в production.

### 10. Полнотекстовый поиск

#### Пример 1 — базовый

**Путь:** `src/playground/FEATURES/10-full-text-search/example-1/`

Полнотекстовый поиск с весами и различными режимами запросов. Таблица `products` содержит генерируемый столбец `search_vector` типа `tsvector`, составленный из трёх полей с разными весами:

```sql
search_vector tsvector GENERATED ALWAYS AS (
  setweight(to_tsvector('english', coalesce(name, '')), 'A') ||
  setweight(to_tsvector('english', coalesce(description, '')), 'B') ||
  setweight(to_tsvector('english', coalesce(immutable_array_to_string(categories, ' '), '')), 'C')
) STORED
```

Вес `A` (наивысший) присвоен названию, `B` — описанию, `C` — категориям. GIN-индекс на `search_vector` обеспечивает быстрый поиск.

Представления демонстрируют разные типы запросов:

- **Булев поиск** — `to_tsquery('database & (postgresql | mysql) & !oracle')` с операторами `&` (AND), `|` (OR), `!` (NOT)
- **Фразовый поиск** — `phraseto_tsquery('open source database')` ищет фразу целиком
- **Поиск с расстоянием** — оператор `<->` задаёт порядок следования слов: `'RDBMS <-> popular'`
- **Подсветка результатов** — `ts_headline()` оборачивает найденные слова в теги `<b>`
- **Ранжирование** — `ts_rank()` оценивает релевантность с учётом весов

#### Пример 2 — продвинутый

**Путь:** `src/playground/FEATURES/10-full-text-search/example-2/`

Поиск, приближённый к продакшену. Вынесен в отдельную схему `search`. Функция `search.search_documents()` принимает текстовый запрос, преобразует его через `websearch_to_tsquery()` (поддерживает естественный язык), ранжирует через `ts_rank_cd()` (cover density ranking) и формирует сниппеты через `ts_headline()` с HTML-разметкой (`<mark>...</mark>`).

Статистика поисковых запросов автоматически обновляется через CTE с `INSERT ... ON CONFLICT` (upsert). Планировщик pg_cron еженедельно оптимизирует индексы (`REINDEX INDEX CONCURRENTLY`) и обновляет статистику планировщика запросов (`ANALYZE`).

### 11. Нечёткий поиск

**Путь:** `src/playground/FEATURES/11-fuzzy-seach/`

*В разработке.* Планируется демонстрация нечёткого поиска с расширениями `pg_trgm` (триграммы) и `unaccent` (нормализация диакритических знаков).

### 12. Материализованные представления с триггерами и уведомлениями

#### Пример 1 — LISTEN/NOTIFY

**Путь:** `src/playground/FEATURES/12-MV_with_trigger_and_notification/example-1/`

Автоматическое обновление MV при изменении данных с уведомлением подписчиков. Материализованное представление `mv_orders_summary` агрегирует заказы по дате и статусу. Триггер `trg_orders_change` (уровень `FOR EACH STATEMENT`) при любом изменении таблицы `orders` вызывает функцию, которая обновляет MV через `REFRESH MATERIALIZED VIEW CONCURRENTLY` и отправляет уведомление через `pg_notify()`.

Раннер подписывается на канал `orders_changes` через `LISTEN`, вставляет данные с задержкой и при получении уведомления повторно читает MV, демонстрируя реактивный паттерн обновления.

Для `CONCURRENTLY` необходим уникальный индекс на MV.

#### Пример 2 — pg_ivm (инкрементальное обновление)

**Путь:** `src/playground/FEATURES/12-MV_with_trigger_and_notification/example-2/`

Инкрементально обновляемые материализованные представления (IMMV) через расширение pg_ivm. В отличие от стандартного `REFRESH MATERIALIZED VIEW`, который пересчитывает весь MV с нуля, IMMV обновляется автоматически и инкрементально при каждом изменении базовой таблицы.

```sql
SELECT pgivm.create_immv('mv_orders_summary', $$
  SELECT (order_date AT TIME ZONE 'UTC')::date AS order_day, ...
  FROM orders GROUP BY order_day, status
$$);
```

Не требует триггеров и уведомлений — изменения в MV отражаются немедленно после `INSERT`/`UPDATE`/`DELETE`.

## Индексы

### 1. Exclusion-индекс (бронирование ресурсов)

**Путь:** `src/playground/INDEXES/1-exclusion-index/`

Exclusion constraint предотвращает пересечение бронирований одного помещения. Расширение `btree_gist` добавляет поддержку GiST-операторов для стандартных типов, что позволяет комбинировать проверку на равенство (`=`) и пересечение временных диапазонов (`&&`).

```sql
EXCLUDE USING GIST (
  room_id WITH =,
  TSRANGE(start_date, end_date) WITH &&
) WHERE (booking_status != 'CANCELED')
```

Ограничение работает на уровне БД: попытка вставить пересекающуюся бронь для того же помещения приведёт к ошибке. Условие `WHERE` делает ограничение частичным — отменённые брони не блокируют новые.

Раннер проверяет сценарии: успешная вставка в разные комнаты, отмена бронирования и повторное использование слота.

## Расширения PostgreSQL

Образ БД (`db.Dockerfile`) собирает и устанавливает расширения из исходников:

| Расширение   | Версия | Назначение                                                 |
|--------------|--------|------------------------------------------------------------|
| `pg_cron`    | 1.6.4  | Планировщик задач внутри PostgreSQL (cron-синтаксис)       |
| `pg_ivm`     | 1.10   | Инкрементально обновляемые материализованные представления |
| `btree_gist` | —      | GiST-операторы для btree-типов (нужен для exclusion index) |
| `pg_trgm`    | —      | Триграммный поиск (подготовлен, не активирован)            |
| `unaccent`   | —      | Нормализация диакритических знаков (подготовлен)           |

Расширения `pg_cron` и `pg_ivm` подключаются через `shared_preload_libraries` в параметрах запуска PostgreSQL. Активация расширений происходит в `init-db/003_main.sql` при первой инициализации базы.

## Подключение к PostgreSQL

### С хост-машины

PostgreSQL доступен на `localhost:5433` (порт 5433, не стандартный 5432 — см. маппинг в docker-compose.yml). Подключиться можно через psql, DBeaver, DataGrip или любой другой клиент:

```bash
psql -h localhost -p 5433 -U postgres -d postgres
```

### pgAdmin

Веб-интерфейс доступен по адресу http://localhost:5051 после запуска контейнеров.

Учётные данные для входа:
- Email: `pgadmin@example.com`
- Пароль: `midapa24`

При добавлении сервера PostgreSQL в pgAdmin (pgAdmin работает внутри Docker-сети, поэтому используется внутренний хост и порт):
- Host: `db`
- Port: `5432`
- Username: `postgres`
- Password: `midapa24`
- Database: `postgres`

## Добавление новых демонстраций

1. Создать директорию в `src/playground/FEATURES/` или `src/playground/INDEXES/` с порядковым номером и названием:

```
src/playground/FEATURES/13-new-feature/
```

2. Создать три файла:

- `up.sql` — SQL для создания таблиц, функций, индексов и заполнения данными
- `index.ts` — TypeScript-раннер с запросами и выводом результатов
- `down.sql` — SQL для очистки (в обратном порядке зависимостей)

3. Создать `init.sh` для последовательного запуска:

```bash
#!/bin/sh
set -e
psql -U postgres -d postgres -f ./src/playground/FEATURES/13-new-feature/up.sql
npx tsx ./src/playground/FEATURES/13-new-feature/index.ts
psql -U postgres -d postgres -f ./src/playground/FEATURES/13-new-feature/down.sql
```

4. Добавить npm-скрипт в `package.json`:

```json
"d:13-new-feature": "npm run d:connect 'sh ./src/playground/FEATURES/13-new-feature/init.sh'"
```

Для подключения к БД из TypeScript используйте `pool` или `client` из `@shared/pool`:

```typescript
import { pool } from '@shared/pool'

const result = await pool.query('SELECT ...')
console.table(result.rows)
```

## Дорожная карта

Отслеживается в `todo.md`. Текущие планы:

**Демонстрации:**
- Нечёткий поиск (pg_trgm + unaccent)
- Materialized View как кэш (timelines) + CDC (table-table stream JOIN)

**Миграции:**
- Миграции данных в продакшене через чистый SQL и через Prisma
- Миграции больших объёмов данных с батчингом и стримингом

**Индексы:**
- Cluster-индекс
- Композитный индекс
- Частичный индекс
- Пошаговая оптимизация запросов

**Инфраструктура:**
- SQL-миграции без ORM
- Бэкап и восстановление БД
- Connection bouncing
- Партиционирование таблиц
- SSL-конфигурация
- Репликация

**Параллелизм:**
- Демонстрация уровней изоляции транзакций
- Advisory locks
