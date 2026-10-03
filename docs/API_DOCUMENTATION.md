# KÖMEKÇI API для Flutter

Документ описывает контракт, который уже реализован в backend. Отдельных тарифов подписки нет: в спецификации одна ежемесячная цена, баланс мастера и автоматическое списание. Flutter не создаёт подписку вручную и не подтверждает банковский платёж.

Локальный адрес: `http://127.0.0.1:8000/api`.

Боевой адрес в проекте не задан. Подставьте его сюда:

```text
https://YOUR-DOMAIN/api
```

Дальше в примерах используется `{base}`.

## Содержание

1. [Общие правила](#1-общие-правила)
2. [Таблица endpoint](#2-таблица-endpoint)
3. [Ошибки](#3-ошибки)
4. [Статусы](#4-статусы)
5. [Authentication](#5-authentication)
6. [Текущий пользователь](#6-текущий-пользователь)
7. [Публичные настройки и цена](#7-публичные-настройки-и-цена)
8. [MASTER](#8-master)
9. [SUBSCRIPTION](#9-subscription)
10. [PHONE PAYMENT](#10-phone-payment)
11. [CARD PAYMENT](#11-card-payment)
12. [CLIENT](#12-client)
13. [Полный сценарий Flutter](#13-полный-сценарий-flutter)

## 1. Общие правила

Заголовок авторизации, где он нужен:

```http
Authorization: Bearer {access_token}
Accept: application/json
```

JSON-запросы:

```http
Content-Type: application/json
```

Загрузка фото и баннера — `multipart/form-data`, не JSON.

Язык текста ошибки: локаль аккаунта, если пользователь уже вошёл. Иначе первые два символа `Accept-Language`: `tk`, `ru`, `en`. Неизвестное значение считается `tk`.

Время в ответах — ISO 8601. На экране показывать `Asia/Ashgabat` (UTC+5).

Списки с `next_cursor`: передать тот же запрос с `?cursor={next_cursor}`. `null` означает, что страниц больше нет.

GET-ответы содержат `ETag`. Повторный запрос с `If-None-Match` может вернуть `304` и пустое тело. Тогда оставить прошлый кэш.

Лимиты:

| Группа | Лимит |
| --- | --- |
| Обычные API | 120 запросов в минуту на аккаунт или IP |
| Поиск мастера | 10 в минуту |
| Проверка никнейма | 30 в минуту на IP |
| Регистрация | 20 в час на IP |
| Запрос OTP | 3 в час на номер, 10 в час на IP, повтор не раньше чем через 60 секунд |
| Запрос связи клиент → мастер | 20 в сутки на клиента |

Пароля нет. Вход только по SMS-коду из 6 цифр. Код живёт 5 минут, неверных попыток не больше 5. Access token живёт 15 минут (`expires_in`: `900`). Refresh token живёт 30 дней. Повторное использование уже погашенного refresh token гасит все refresh token этого аккаунта.

## 2. Таблица endpoint

| Method | Endpoint | Auth | Описание |
| --- | --- | --- | --- |
| GET | `/settings/public` | нет | Цена подписки, валюта, поддержка |
| GET | `/auth/nickname/available` | нет | Свободен ли никнейм |
| POST | `/auth/register` | нет | Регистрация, затем SMS |
| POST | `/auth/otp/request` | нет | Код для входа |
| POST | `/auth/otp/verify` | нет | Проверка кода, выдача токенов |
| POST | `/auth/refresh` | нет | Новая пара токенов |
| POST | `/auth/logout` | Bearer | Погасить refresh token |
| GET | `/me` | Bearer | Текущий профиль |
| PATCH | `/me` | Bearer | Имя, ник, язык, тема, фото, уведомления |
| POST | `/me/phone` | Bearer | SMS для смены телефона |
| POST | `/me/phone/verify` | Bearer | Подтвердить новый телефон |
| DELETE | `/me` | Bearer | Удалить аккаунт |
| GET | `/me/notifications` | Bearer | Входящие уведомления |
| POST | `/me/notifications/{id}/read` | Bearer | Отметить прочитанным |
| POST | `/me/devices` | Bearer | Сохранить FCM token |
| DELETE | `/me/devices` | Bearer | Удалить FCM token |
| GET | `/me/profile` | Bearer, master | Публичный профиль мастера |
| PATCH | `/me/profile` | Bearer, master | Адрес, описание, ссылки, баннер |
| GET | `/me/services` | Bearer, master | Услуги |
| POST | `/me/services` | Bearer, master | Создать услугу |
| PATCH | `/me/services/{id}` | Bearer, master | Изменить услугу |
| DELETE | `/me/services/{id}` | Bearer, master | Удалить услугу |
| GET | `/me/schedule` | Bearer, master | График, выходные, отпуск |
| PUT | `/me/schedule` | Bearer, master | Сохранить неделю |
| POST | `/me/schedule/overrides` | Bearer, master | Выходной или особые часы |
| DELETE | `/me/schedule/overrides/{id}` | Bearer, master | Удалить исключение |
| POST | `/me/vacations` | Bearer, master | Отпуск |
| DELETE | `/me/vacations/{id}` | Bearer, master | Удалить отпуск |
| GET | `/me/calendar` | Bearer, master | Записи за период |
| GET | `/me/clients` | Bearer, master | Список клиентов |
| GET | `/me/clients/{id}` | Bearer, master | Карточка клиента |
| PATCH | `/me/clients/{id}` | Bearer, master | Личная заметка |
| DELETE | `/me/clients/{id}` | Bearer, master | Убрать клиента |
| POST | `/me/appointments` | Bearer, master | Ручная запись |
| PATCH | `/me/appointments/{id}/status` | Bearer, master | completed, cancelled, no_show |
| PATCH | `/me/appointments/{id}/move` | Bearer, master | Перенести запись |
| GET | `/me/connection-requests` | Bearer, master | Входящие запросы |
| POST | `/me/connection-requests/{id}/accept` | Bearer, master | Принять |
| POST | `/me/connection-requests/{id}/decline` | Bearer, master | Отклонить |
| GET | `/me/billing` | Bearer, master | Баланс, подписка, номер для оплаты |
| GET | `/me/billing/transactions` | Bearer, master | Журнал пополнений и списаний |
| POST | `/me/billing/topup` | Bearer, master | Начать оплату с телефона или картой |
| GET | `/me/billing/phone` | Bearer, master | Статус телефонных платежей |
| GET | `/me/billing/cards/{id}` | Bearer, master | Статус карточного платежа после проверки банка |
| GET | `/payments/result` | нет | Тот же карточный результат по `orderId` банка |
| GET | `/masters/lookup` | Bearer, client | Точный поиск мастера |
| POST | `/connections` | Bearer, client | Запрос на связь |
| GET | `/connections` | Bearer, client | Мои мастера |
| PATCH | `/connections/{id}/active` | Bearer, client | Сделать мастера активным |
| DELETE | `/connections/{id}` | Bearer, client | Удалить связь |
| GET | `/masters/{id}` | Bearer, client | Профиль связанного мастера |
| GET | `/masters/{id}/services` | Bearer, client | Его видимые услуги |
| GET | `/masters/{id}/availability` | Bearer, client | Свободные слоты |
| GET | `/appointments` | Bearer, client | Предстоящие или история |
| POST | `/appointments` | Bearer, client | Записаться |
| PATCH | `/appointments/{id}/move` | Bearer, client | Перенести свою запись |
| POST | `/appointments/{id}/cancel` | Bearer, client | Отменить |
| POST | `/appointments/{id}/late` | Bearer, client | Опоздание на 5 или 10 минут |
| POST | `/appointments/{id}/rebook` | Bearer, client | Записаться снова |
| POST | `/waitlist/{id}/accept` | Bearer, client | Принять более ранний слот |
| POST | `/waitlist/{id}/decline` | Bearer, client | Отказаться от предложения |

`POST /transactions` и `POST /transactions/pending` вызывает платёжный шлюз, не приложение. Flutter их не использует.

## 3. Ошибки

Тело ошибки всегда такое:

```json
{
  "error": "SLOT_TAKEN",
  "message": "К сожалению, это время уже занято.",
  "message_tk": "Gynansak-da, bu wagt eýýäm tutuldy.",
  "message_ru": "К сожалению, это время уже занято.",
  "message_en": "Unfortunately, this time is already taken.",
  "details": {}
}
```

`message` совпадает с языком пользователя. `details` — объект. У ошибки проверки полей Laravel кладёт туда имена полей и массив строк.

Проверка полей, HTTP 422, `error` = `VALIDATION`:

```json
{
  "error": "VALIDATION",
  "message": "Данные не прошли проверку.",
  "message_tk": "Maglumatlar nädogry.",
  "message_ru": "Данные не прошли проверку.",
  "message_en": "The given data was invalid.",
  "details": {
    "phone": ["The phone field format is invalid."]
  }
}
```

| HTTP | `error` | Когда |
| --- | --- | --- |
| 401 | `UNAUTHENTICATED` | Нет Bearer, токен просрочен или аккаунт не активен |
| 403 | `FORBIDDEN` | Роль не та: клиент вызвал метод мастера или наоборот |
| 403 | `NOT_CONNECTED` | Клиент обращается к мастеру без принятой связи |
| 403 | `SUBSCRIPTION_SUSPENDED` | Мастер пытается создать или перенести запись без активной подписки |
| 404 | `NOT_FOUND` | Нет записи, услуги, клиента, связи |
| 404 | `MASTER_NOT_FOUND` | Поиск мастера ничего не нашёл |
| 404 | `PHONE_NOT_FOUND` | На этот номер нет активного аккаунта |
| 404 | `PAYMENT_UNAVAILABLE` | Для оплаты с телефона сейчас нет свободного номера |
| 409 | `SLOT_TAKEN` | Время занято. В `details.suggested_slots` до 5 ближайших слотов |
| 422 | `VALIDATION` | Поле не прошло правило |
| 422 | `NICKNAME_TAKEN` | Ник занят. При регистрации в `details.suggestions` три варианта |
| 422 | `PHONE_TAKEN` | Телефон уже зарегистрирован |
| 422 | `OTP_INVALID` | Неверный код |
| 422 | `OTP_EXPIRED` | Код истёк или попытки кончились |
| 422 | `PAST_TIME` | Время уже прошло или ближе, чем `min_lead_min` |
| 422 | `OUTSIDE_WORKING_HOURS` | Вне графика, перерыва, отпуска или выходного |
| 422 | `APPOINTMENT_LOCKED` | Запись уже нельзя изменить |
| 422 | `SERVICE_UNAVAILABLE` | Услуга скрыта или не этого мастера |
| 422 | `OFFER_EXPIRED` | Предложение более раннего слота истекло |
| 422 | `ALREADY_CONNECTED` | Связь уже есть |
| 422 | `REQUEST_PENDING` | Запрос этому мастеру уже отправлен |
| 424 | `PAYMENT_UNAVAILABLE` | Банк не создал заказ карты. Текст банка в `details.bank` |
| 429 | `RATE_LIMITED` | Слишком часто. При повторном OTP в `details.retry_after` секунды |
| 500 | `ERROR` | Необработанная ошибка |
| 503 | `PAYMENT_UNAVAILABLE` | У сервера нет данных банка или SMS-шлюз недоступен |
| 503 | `SMS_UNAVAILABLE` | SMS не ушло |

Успешный платёж никогда не приходит как ошибка. Неуспех карты — это HTTP 200 и `status`: `failed` или `unfinished`.

## 4. Статусы

Значения в API строчные. В PDF они написаны заглавными, в JSON их нет.

### Подписка мастера

Поле `subscription_status`.

| status | Значение | Что делает Flutter |
| --- | --- | --- |
| `suspended` | Баланса не хватило или подписка ещё не оплачена. Новые записи закрыты | Показать баннер и кнопку пополнения. Календарь и клиенты доступны для просмотра |
| `grace` | Льготный период, записи ещё принимаются | Показать, что оплата скоро потребуется. `accepting_bookings` при этом `true` |
| `active` | Подписка оплачена | Открыть создание записей |

`accepting_bookings` равен `true` только для `active` и `grace`. После успешного пополнения сервер сам списывает цену, если срок подошёл, и сам ставит `active`. Flutter статус не отправляет.

`paid_until` — конец оплаченного месяца. `next_charge_at` — момент следующего списания. Пока подписка не активна, оба поля могут быть `null`.

### Журнал баланса

`GET /me/billing/transactions`.

| Поле | Значения |
| --- | --- |
| `type` | `topup` пополнение, `charge` списание подписки, `refund` возврат |
| `method` | `mobile`, `card`, `system` для списания |
| `status` | `succeeded` проведено, `pending` ждёт, `failed` не прошло |

В истории Flutter показывает дату, тип, сумму и `balance_after`.

### Телефонный платёж

`GET /me/billing/phone`, массив `payments`.

| status | `pending_reason` | Значение | Что делает Flutter |
| --- | --- | --- | --- |
| `pending` | `amount_too_low` | Перевод пришёл, но один перевод меньше 20.00 TMT. На баланс ещё не зачислен | Показать, что нужно отправить одним переводом не меньше `phone_min_amount`. Подписку не считать оплаченной |
| `pending` | `user_not_found` | Деньги пришли до регистрации мастера с этим номером | После входа сервер зачислит их сам. Обновить `GET /me/billing` |
| `completed` | `null` | Сумма зачислена | Обновить баланс и подписку |
| `rejected` | прежняя причина или `null` | Администратор отклонил ожидание. Деньги не зачислены | Показать отказ, не активировать подписку |

Отдельных статусов `cancelled` и `expired` у телефонного платежа нет.

### Карточный платёж

| status | Значение | Что делает Flutter |
| --- | --- | --- |
| `unfinished` | Заказ создан или банк ещё не закончил оплату | Оставить экран ожидания и спросить статус ещё раз |
| `unknown` | Сервер ещё не получил код банка | Повторить проверку |
| `success` | Банк подтвердил оплату, сумма зачислена один раз | Закрыть платёжную страницу и запросить `GET /me/billing` |
| `failed` | Банк отказал, время вышло или заказ не создан | Показать ошибку. Подписка от этого платежа не меняется |

Редирект браузера с банка сам по себе не означает успех. Успех — только `status: success` после ответа API.

### Запись

`expected`, `completed`, `cancelled`, `no_show`. Источник: `online` или `manual`.

### Связь

`pending`, `accepted`, `declined`, `removed`.

### Аккаунт

`pending` до подтверждения SMS, затем `active`. Удалённый — `deleted` и больше не входит.

## 5. Authentication

### GET `/auth/nickname/available`

Без токена.

Query: `nickname`, строка.

Ответ 200:

```json
{
  "available": true,
  "suggestions": []
}
```

Если занят, `available` равен `false`, в `suggestions` три свободных варианта.

### POST `/auth/register`

Без токена. `multipart/form-data`. HTTP 201.

| Поле | Правило |
| --- | --- |
| `role` | `client` или `master` |
| `name` | 2–50 символов |
| `nickname` | `^[a-z_][a-z0-9_]{2,19}$` |
| `phone` | `+993` и 8 цифр |
| `photo` | изображение, до 8 МБ |
| `locale` | необязательно: `tk`, `ru`, `en` |
| `address` | обязательно для `master`, до 255 |
| `description` | обязательно для `master`, до 2000 |
| `banner` | обязательно для `master`, изображение до 8 МБ |
| `instagram_url`, `tiktok_url` | необязательный URL |
| `other_links[]` | до 10 URL |

Ответ:

```json
{
  "status": "otp_sent"
}
```

Токенов здесь нет. Дальше `POST /auth/otp/verify` с тем же телефоном.

Ошибки: `PHONE_TAKEN` 422, `NICKNAME_TAKEN` 422, `VALIDATION` 422, `SMS_UNAVAILABLE` 503, `RATE_LIMITED` 429.

### POST `/auth/otp/request`

Вход уже существующего активного аккаунта.

```json
{
  "phone": "+99361234567"
}
```

Ответ 200: `{ "status": "otp_sent" }`.

Неизвестный номер: `PHONE_NOT_FOUND` 404.

### POST `/auth/otp/verify`

И для регистрации, и для входа.

```json
{
  "phone": "+99361234567",
  "code": "123456"
}
```

Ответ 200:

```json
{
  "access_token": "eyJ...",
  "refresh_token": "случайная строка",
  "token_type": "Bearer",
  "expires_in": 900
}
```

Сохранить оба токена. Если этот телефон заплатил до регистрации, сервер в этот момент зачисляет ожидающие переводы и при достаточной сумме сам активирует подписку.

### POST `/auth/refresh`

```json
{
  "refresh_token": "сохранённый refresh token"
}
```

Ответ — новая пара, старый refresh token больше не действует.

### POST `/auth/logout`

Bearer.

Тело необязательно. Если передан `refresh_token`, гасится только он. Если нет — гасятся все refresh token аккаунта.

Ответ: `{ "status": "ok" }`.

## 6. Текущий пользователь

### GET `/me`

Bearer. Ответ 200, объект в `data`.

Общие поля: `id`, `role` (`client` или `master`), `name`, `nickname`, `phone`, `locale`, `theme` (`ivory`, `onyx`, `champagne`, `rose`), `photo_url`, `photo`, `notification_prefs`.

`photo` — объект адресов размеров `"64"`, `"256"`, `"1080"` или `null`. `photo_url` — размер 256.

Для мастера дополнительно:

```json
{
  "data": {
    "id": 12,
    "role": "master",
    "subscription_status": "suspended",
    "accepting_bookings": false,
    "profile": {
      "id": 12,
      "name": "Ayna",
      "nickname": "ayna_style",
      "address": "Ashgabat",
      "description": "Barber",
      "banner_url": null,
      "instagram_url": null,
      "tiktok_url": null,
      "other_links": []
    }
  }
}
```

Для клиента: `active_master` (краткий мастер или `null`) и `next_appointment` (ближайшая запись `expected` или `null`).

### PATCH `/me`

Bearer. JSON или multipart, если меняется фото.

Можно передать часть полей: `name`, `nickname`, `locale`, `theme`, `notification_prefs`, `photo`.

`notification_prefs` у мастера — объект `{"N-01": true, ...}` только для кодов `N-01` … `N-19`. У клиента три ключа: `reminders`, `earlier_slot`, `master_messages`.

Ответ — тот же объект, что у `GET /me`.

### POST `/me/phone` и POST `/me/phone/verify`

Смена телефона. Сначала `{ "phone": "+993..." }` → `{ "status": "otp_sent" }`. Затем `phone` и `code`. Ответ — обновлённый `GET /me`.

Телефон мастера — это номер, с которого должна прийти оплата с телефона. После смены платить нужно уже с нового номера.

### DELETE `/me`

```json
{
  "confirm": true
}
```

Ответ: `{ "status": "ok" }`. Сессия на сервере погашена.

### Уведомления и устройство

`GET /me/notifications?cursor=` — только канал inbox, 20 штук.

Элемент: `id`, `event_code`, `title`, `body`, `payload`, `read_at`, `sent_at`.

`POST /me/notifications/{id}/read` отмечает прочитанным.

Коды из спецификации, которые сервер умеет слать: `N-01` … `N-19`. Для подписки важны `N-13` списание, `N-14` `N-15` `N-16` напоминания, `N-17` подписка остановлена, `N-18` подписка снова активна, `N-19` пополнение прошло.

`POST /me/devices`:

```json
{
  "token": "fcm token",
  "platform": "android"
}
```

`platform`: `android` или `ios`. Ответ `{ "status": "ok" }`.

`DELETE /me/devices` с тем же `token`.

## 7. Публичные настройки и цена

### GET `/settings/public`

Без токена. Это экран «для мастеров» до регистрации. Отдельного списка тарифов нет: цена одна, срок один месяц, пакеты не выбираются.

```json
{
  "subscription_price": "20.00",
  "currency": "TMT",
  "support_contact": "",
  "locales": ["tk", "ru", "en"]
}
```

`subscription_price` приходит строкой с двумя знаками. Показывать её как цену в месяц. Идентификатора плана нет и отправлять его не нужно.

## 8. MASTER

Все пути ниже требуют Bearer и `role: master`. Иначе 403 `FORBIDDEN`.

### Профиль

`GET /me/profile` — баннер, фото, имя, ник, адрес, описание, ссылки, `accepting_bookings`.

`PATCH /me/profile` — multipart, если есть баннер.

| Поле | Правило |
| --- | --- |
| `address` | строка до 255, если передана |
| `description` | строка до 2000, если передана |
| `instagram_url`, `tiktok_url` | URL или пусто |
| `other_links` | массив до 10 URL |
| `banner` | изображение до 8 МБ |

Имя, ник и фото меняются через `PATCH /me`, не через этот метод.

### Услуги

`GET /me/services` → `{ "data": [ ... ] }`.

Услуга: `id`, `name`, `description`, `price`, `duration_min`, `is_hidden`, `sort_order`, `photo_url`, `photo`.

`POST /me/services`, multipart, 201. Обязательны `photo`, `name` (2–60), `price` (0…999999), `duration_min` (5…480). Необязательны `description` до 300, `is_hidden`, `sort_order`.

`PATCH /me/services/{id}` — те же поля, все необязательны, кроме переданных.

`DELETE /me/services/{id}` → `{ "status": "ok" }`. Прошлые записи сохраняют название, цену и длительность.

### График

`GET /me/schedule`:

```json
{
  "grid_step_min": 15,
  "min_lead_min": 30,
  "days": [],
  "overrides": [],
  "vacations": []
}
```

`days` — семь объектов с `weekday` от 0 до 6, `is_working`, `start_time`, `end_time`, `break_start`, `break_end`. Время `HH:mm` или `null`.

`PUT /me/schedule` заменяет неделю целиком. `days` обязателен и ровно из 7 элементов. Рабочий день без начала и конца, или конец не позже начала, даёт `VALIDATION` 422. Перерыв задаётся парой либо не задаётся.

`POST /me/schedule/overrides`, 201:

```json
{
  "date": "2026-10-15",
  "type": "day_off",
  "start_time": null,
  "end_time": null
}
```

`type`: `day_off` или `custom_hours`. Для `custom_hours` обязательны `start_time` и `end_time`.

`POST /me/vacations`: `start_date`, `end_date` не раньше начала. 201.

Удаление исключения и отпуска: `DELETE` и `{ "status": "ok" }`.

### Календарь

`GET /me/calendar?from=2026-10-01&to=2026-10-07`

Оба параметра обязательны. Ответ `{ "data": [ запись мастера ] }`.

Запись мастера:

```json
{
  "id": 41,
  "starts_at": "2026-10-01T10:00:00+05:00",
  "ends_at": "2026-10-01T10:30:00+05:00",
  "status": "expected",
  "note": null,
  "source": "online",
  "late_minutes": null,
  "no_show_suggested": false,
  "service": {
    "id": 3,
    "name": "Haircut",
    "price": "50.00",
    "duration_min": 30
  },
  "client": {
    "id": "a15",
    "name": "Ali",
    "nickname": "ali_user",
    "phone": "+99361111111",
    "photo_url": null,
    "offline": false
  }
}
```

У офлайн-клиента `id` начинается с `o`, `offline` равен `true`, `nickname` равен `null`. `no_show_suggested` становится `true`, когда запись всё ещё `expected`, а с начала прошло окно неявки.

### Клиенты

`GET /me/clients?query=&sort=nearest&cursor=`

`sort`: `nearest` (по умолчанию), `name`, `last_visit`, `visits`. `query` ищет имя, ник или телефон.

Элемент `data`: `id` (`c12` для связи, `o4` для офлайн), `offline`, `name`, `nickname`, `phone`, `photo_url`, `appointment`, `last_visit`, `visits`, `no_shows`, `spend`, `status`.

`appointment`, если есть: `id`, `starts_at`, `service_name`, `status`.

`GET /me/clients/c12`:

```json
{
  "data": {
    "client": {},
    "private_note": null,
    "history": []
  }
}
```

История, до 50 записей: `id`, `starts_at`, `ends_at`, `status`, `service_name`, `price`, `duration_min`, `note`, `late_minutes`.

`PATCH /me/clients/{id}`: `{ "private_note": "текст до 2000" }`. Ответ `{ "status": "ok" }`.

`DELETE /me/clients/{id}` убирает связь или помечает офлайн-клиента удалённым.

### Ручная запись

`POST /me/appointments`, JSON, 201. Подписка должна принимать записи, иначе `SUBSCRIPTION_SUSPENDED` 403.

| Поле | Правило |
| --- | --- |
| `name` | 2–50 |
| `phone` | необязательно, `+993` и 8 цифр |
| `service_id` | услуга этого мастера |
| `starts_at` | дата и время, которые сервер читает в `Asia/Ashgabat` |

Если телефон совпадает со связанным клиентом, запись привязывается к нему. Иначе создаётся офлайн-клиент.

Ответ — запись мастера в `data`.

### Статус и перенос

`PATCH /me/appointments/{id}/status`:

```json
{
  "status": "completed"
}
```

Допустимо: `completed`, `cancelled`, `no_show`.

`PATCH /me/appointments/{id}/move`: `{ "starts_at": "2026-10-02 11:00:00" }`.

Занятое время: 409 `SLOT_TAKEN`.

### Запросы клиентов

`GET /me/connection-requests`:

```json
{
  "data": [
    {
      "id": 8,
      "requested_at": "2026-10-01T12:00:00+05:00",
      "client": {
        "name": "Ali",
        "nickname": "ali_user",
        "photo_url": null
      }
    }
  ]
}
```

`POST /me/connection-requests/{id}/accept` — 200, в `data` строка связи со `status: "accepted"`.

`POST /me/connection-requests/{id}/decline` — `{ "status": "ok" }`.

Если запрос уже решён: `NOT_FOUND` 404.

## 9. SUBSCRIPTION

Отдельного `GET /plans` нет. Flutter берёт цену из `GET /settings/public` до входа и из `GET /me/billing` после входа.

Поля подписки на `GET /me/billing`:

| Поле | Смысл |
| --- | --- |
| `balance` | Текущий баланс, строка с двумя знаками |
| `subscription_price` | Цена одного месяца |
| `subscription_status` | `active`, `suspended`, `grace` |
| `next_charge_at` | Следующее списание или `null` |
| `paid_until` | Оплачено до или `null` |
| `accepting_bookings` | Можно ли создавать записи |
| `payment_methods` | Всегда `["mobile", "card"]` |
| `phone` | Номер, на который мастер переводит деньги, или `null` |
| `phone_daily_limit` | `7`. Сколько переводов в день принимает один номер |
| `phone_min_amount` | `"20.00"`. Минимум одного перевода, после которого деньги зачисляются |

Пример приостановленной подписки:

```json
{
  "balance": "0.00",
  "subscription_price": "20.00",
  "subscription_status": "suspended",
  "next_charge_at": null,
  "paid_until": null,
  "accepting_bookings": false,
  "payment_methods": ["mobile", "card"],
  "phone": "+99365000001",
  "phone_daily_limit": 7,
  "phone_min_amount": "20.00"
}
```

После зачисления сервер сам списывает `subscription_price`, если подписка не активна или срок уже наступил. Flutter после `success` или `completed` вызывает этот метод ещё раз. Активная подписка выглядит так: `subscription_status` = `active`, `accepting_bookings` = `true`, `paid_until` заполнен.

История: `GET /me/billing/transactions?cursor=`.

```json
{
  "data": [
    {
      "id": 90,
      "type": "charge",
      "amount": "20.00",
      "balance_after": "0.00",
      "method": "system",
      "status": "succeeded",
      "created_at": "2026-10-01T12:05:00+05:00"
    },
    {
      "id": 89,
      "type": "topup",
      "amount": "20.00",
      "balance_after": "20.00",
      "method": "card",
      "status": "succeeded",
      "created_at": "2026-10-01T12:05:00+05:00"
    }
  ],
  "next_cursor": null
}
```

Сумма пополнения может быть любой от `1.00`. Это не выбор тарифа. Месяц всё равно стоит `subscription_price`. Лишнее остаётся на балансе.

## 10. PHONE PAYMENT

Оплату с телефона инициирует не запрос «создать транзакцию», а перевод с номера мастера на номер, который выдал сервер. Приложение не передаёт sender, receiver и сумму в шлюз. Эти поля принимает только сервер платёжной системы.

### Шаг 1. Получить номер

`POST /me/billing/topup`

```json
{
  "amount": 20,
  "method": "mobile"
}
```

`amount` обязателен, число от 1 до 100000. Для телефона сервер его не списывает и не сохраняет как платёж. Он только возвращает его обратно. Реальная сумма — та, которую мастер отправит переводом.

Ответ 200:

```json
{
  "payment_method": "mobile",
  "status": "pending",
  "amount": "20.00",
  "phone": "+99365000001",
  "phone_used": 0,
  "phone_daily_limit": 7,
  "phone_min_amount": "20.00",
  "balance": "0.00",
  "subscription_status": "suspended"
}
```

`status: pending` здесь значит «номер выдан, перевода ещё нет», а не строку в базе платежей.

Если свободного номера нет: 404 `PAYMENT_UNAVAILABLE`. Тот же номер можно заранее увидеть в `GET /me/billing` в поле `phone`. Если оно `null`, оплату с телефона начать нельзя.

Показать мастеру: перевести деньги со своего зарегистрированного номера `GET /me` → `phone` на `phone` из ответа. Один перевод должен быть не меньше `phone_min_amount`, иначе он копится и подписку не включает.

Номер, который сегодня уже принял 7 переводов, сервер больше не выдаёт. На следующий день лимит начинается заново. Flutter лимит не считает.

### Шаг 2. Ждать зачисление

Пока мастер платит, опрашивать:

`GET /me/billing/phone`

```json
{
  "payment_method": "mobile",
  "balance": "0.00",
  "subscription_status": "suspended",
  "paid_until": null,
  "payments": [
    {
      "id": 4,
      "amount": "10.00",
      "status": "pending",
      "pending_reason": "amount_too_low",
      "receiver": "+99365000001",
      "time": "01/10/2026 18:00:00",
      "created_at": "2026-10-01T18:00:01+05:00"
    }
  ]
}
```

Пустой `payments` значит, что перевод ещё не дошёл.

Когда последний нужный платёж `completed`, вызвать `GET /me/billing`. Если суммы хватило на цену месяца, `subscription_status` уже `active`. Если перевод был меньше цены и это единственные деньги, статус останется `suspended`, а `balance` покажет остаток.

Повторный одинаковый отчёт шлюза не зачисляет деньги второй раз. Повторный опрос `GET /me/billing/phone` безопасен.

## 11. CARD PAYMENT

Flutter открывает страницу банка и потом спрашивает результат у сервера. Код банка приложение не проверяет.

### Шаг 1. Создать заказ

`POST /me/billing/topup`

```json
{
  "amount": 20,
  "method": "card"
}
```

`amount` — сумма пополнения в TMT, от 1 до 100000. Это не идентификатор тарифа.

Ответ 200:

```json
{
  "payment_method": "card",
  "status": "unfinished",
  "card_transaction_id": 15,
  "bank_order_id": "bank-order-id",
  "form_url": "https://mpi.gov.tm/pay/...",
  "amount": "20.00",
  "balance": "0.00",
  "subscription_status": "suspended"
}
```

Сохранить `card_transaction_id` и `bank_order_id`. Открыть `form_url` во WebView. Пока статус `unfinished`, подписка не меняется.

Если банк не выдал заказ: 424 `PAYMENT_UNAVAILABLE`. Если на сервере нет доступа к банку: 503 `PAYMENT_UNAVAILABLE`.

### Шаг 2. Дождаться возврата

Банк возвращает браузер на адрес сервера с query `orderId`. Это `bank_order_id`, не `card_transaction_id`.

Flutter перехватывает URL, закрывает WebView и не считает оплату успешной только из-за того, что страница открылась.

### Шаг 3. Спросить сервер

Любой из двух методов. Оба запрашивают банк и при `success` один раз пополняют баланс и, если нужно, списывают подписку.

С токеном мастера:

`GET /me/billing/cards/15`

```json
{
  "card_transaction_id": 15,
  "status": "success",
  "amount": "20.00",
  "bank_error_code": 0,
  "bank_order_status": 2,
  "balance": "0.00",
  "subscription_status": "active",
  "paid_until": "2026-11-01T12:05:00+05:00"
}
```

Чужая или несуществующая карта: 404 `NOT_FOUND`.

Без токена, если WebView видит только `orderId`:

`GET /payments/result?orderId=bank-order-id`

```json
{
  "payment_method": "card",
  "card_transaction_id": 15,
  "bank_order_id": "bank-order-id",
  "status": "success",
  "amount": "20.00",
  "bank_error_code": 0,
  "bank_order_status": 2,
  "balance": "0.00",
  "subscription_status": "active",
  "paid_until": "2026-11-01T12:05:00+05:00"
}
```

Нет `orderId`: 422 `VALIDATION`. Неизвестный `orderId`: 404 `NOT_FOUND`.

Если статус `unfinished` или `unknown`, повторить этот GET. Если `failed`, показать отказ и оставить прежний экран подписки. Повторный GET после `success` не списывает и не пополняет второй раз.

`balance` в ответе уже после списания месяца, если списание произошло. Поэтому при пополнении ровно на цену месяца баланс может быть `0.00`, а подписка при этом `active`.

Дальше `GET /me/billing` и `GET /me/billing/transactions`.

## 12. CLIENT

Нужен Bearer и `role: client`.

### Поиск и связь

`GET /masters/lookup?q=`

`q` короче 3 символов → `{ "data": null }` и HTTP 200. Иначе точное совпадение ника или телефона. Частичный поиск не находит мастера.

Ответ — краткий мастер: `id`, `name`, `nickname`, `photo_url`, `address`, `accepting_bookings`.

Нет мастера: 404 `MASTER_NOT_FOUND`.

`POST /connections`: `{ "master_id": 12 }`, 201.

```json
{
  "data": {
    "id": 8,
    "status": "pending",
    "active": false,
    "master": {
      "id": 12,
      "name": "Ayna",
      "nickname": "ayna_style",
      "photo_url": null,
      "address": "Ashgabat",
      "accepting_bookings": false
    }
  }
}
```

`GET /connections` — массив таких объектов со статусом `pending` или `accepted`.

`PATCH /connections/{id}/active` делает принятую связь активной.

`DELETE /connections/{id}` → `{ "status": "ok" }`.

### Мастер, услуги, слоты

Только после `accepted`. Иначе 403 `NOT_CONNECTED`.

`GET /masters/{id}` — полный профиль, как его видит клиент.

`GET /masters/{id}/services`:

```json
{
  "accepting_bookings": true,
  "data": []
}
```

Скрытые услуги клиента не приходят.

`GET /masters/{id}/availability?service_id=3&date=2026-10-02`

Один день:

```json
{
  "accepting_bookings": true,
  "date": "2026-10-02",
  "slots": ["10:00", "10:15", "10:30"]
}
```

Без `date`, на диапазон до 31 дня: `from` и `to`. Ответ содержит `dates` — объект, где ключ это дата, значение массив слотов. Если дней нет, `dates` равен `{}`.

Если мастер не принимает записи, HTTP всё равно 200:

```json
{
  "accepting_bookings": false,
  "error": "SUBSCRIPTION_SUSPENDED",
  "message": "Мастер временно не принимает новые записи.",
  "message_tk": "Ussat wagtlaýyn täze ýazgylary kabul etmeýär.",
  "message_ru": "Мастер временно не принимает новые записи.",
  "message_en": "The master is temporarily not accepting new bookings.",
  "slots": [],
  "dates": {}
}
```

Существующие записи клиента при этом не отменяются.

### Записи клиента

`GET /appointments?scope=upcoming|history&master_id=&status=&cursor=`

`scope` по умолчанию `upcoming` (`expected`). `history` — `completed`, `cancelled`, `no_show`. `status` может сузить выборку.

Элемент:

```json
{
  "id": 41,
  "starts_at": "2026-10-02T10:00:00+05:00",
  "ends_at": "2026-10-02T10:30:00+05:00",
  "status": "expected",
  "note": "shorter on the sides",
  "late_minutes": null,
  "waitlist_earlier": false,
  "service": {
    "id": 3,
    "name": "Haircut",
    "price": "50.00",
    "duration_min": 30
  },
  "master": {
    "id": 12,
    "name": "Ayna",
    "nickname": "ayna_style",
    "photo_url": null
  }
}
```

`POST /appointments`, 201:

```json
{
  "service_id": 3,
  "starts_at": "2026-10-02 10:00:00",
  "note": "shorter on the sides",
  "waitlist_earlier": true
}
```

`note` до 200 символов. `waitlist_earlier` просит сообщить, если освободится более раннее время.

Необязательный заголовок `Idempotency-Key`. Повтор с тем же ключом не создаёт вторую запись.

`PATCH /appointments/{id}/move`: `{ "starts_at": "..." }`.

`POST /appointments/{id}/cancel` без тела.

`POST /appointments/{id}/late`: `{ "minutes": 5 }` или `10`.

`POST /appointments/{id}/rebook`, 201. `starts_at` необязателен. Без него сервер ищет такое же время в ближайшие дни. Если занято, 409 и в `details` есть `suggested_slots`, `date`, `service_id`, `master_id`.

`POST /waitlist/{id}/accept` переносит запись на предложенное время.

`POST /waitlist/{id}/decline` → `{ "status": "ok" }`. Если предложение уже недействительно: `OFFER_EXPIRED` 422.

## 13. Полный сценарий Flutter

### Вход

```text
Роль
  → GET /auth/nickname/available
  → POST /auth/register
  → пользователь вводит SMS
  → POST /auth/otp/verify
  → сохранить access_token и refresh_token
  → GET /me
  → если role = master, открыть кабинет мастера
```

Повторный вход: `POST /auth/otp/request`, затем `POST /auth/otp/verify`.

Когда access token отвечает 401, вызвать `POST /auth/refresh`. Если refresh тоже вернул 401, отправить пользователя на ввод телефона. `expires_in` равен 900 секундам: токен живёт 15 минут.

### Подписка

```text
До регистрации мастера
  → GET /settings/public
  → показать subscription_price TMT / месяц
После входа
  → GET /me/billing
  → показать balance, subscription_status, paid_until, next_charge_at
  → GET /me/billing/transactions для истории
```

Выбора плана нет. Мастер выбирает только способ пополнения и сумму.

### Телефон

```text
POST /me/billing/topup  { amount, method: "mobile" }
  → показать phone и phone_min_amount
  → мастер переводит деньги со своего номера вне приложения
  → GET /me/billing/phone, пока перевод не появится
  → pending + amount_too_low: попросить один перевод от 20.00
  → completed: GET /me/billing
  → subscription_status = active: убрать баннер
```

Приложение не вызывает платёжный шлюз и не отправляет номер получателя как подтверждение оплаты.

### Карта

```text
POST /me/billing/topup  { amount, method: "card" }
  → открыть form_url
  → банк возвращает orderId
  → GET /me/billing/cards/{card_transaction_id}
     или GET /payments/result?orderId=
  → unfinished или unknown: повторить
  → failed: показать отказ, подписку не менять
  → success: GET /me/billing
  → subscription_status = active
```

Flutter не отправляет в банк `errorCode` и не выставляет статус подписки.
