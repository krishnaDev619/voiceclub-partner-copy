# VoiceClub Partner: backend changes for backend-driven languages

**For:** Backend Lead  
**From:** Frontend  
**Date:** 23 Sep 2026  
**Related:** customer app doc `frontend/docs/demand-backend-language-changes.md`

**Goal:** after this project, a new language ships in the partner app with no app release. The backend adds the language and publishes its content, and the app picks it up on the next open.

**Shape:** two new APIs cover the whole language setup. One returns the language list. The other returns one JSON with everything for a language. That JSON has a `last_updated` field, which the app uses to decide whether to download it again or use its cache.

## How the partner app uses language (context)

The partner app has two separate language concepts, and both stay:

| Concept | Where it's picked | Stored | Drives |
|---|---|---|---|
| **App language** (UI) | First screen, before login | On the device only today (`appLocale`) | UI text, onboarding videos (meeting, testimonial, agreement, question videos), language preselect in onboarding |
| **Speaking languages** | Onboarding question + profile | Backend (`first_language`, `second_language`, returned as `primary_language` / `secondary_language`) | Call matching, intro audio, OneScore demo videos, reward audio, e-sign video, WhatsApp group |

Today both are hardcoded in the app. The app language list is fixed to Hindi, Tamil and Telugu. The UI is always English, because the saved choice is never applied. The speaking-language list in onboarding is a fixed list of 12 languages, and every piece of language-specific media is a hardcoded Hindi, Tamil or Telugu URL. Several GrowthBook flags are also evaluated in the app, and content is then picked by language.

## 1. The two APIs

| # | API | Auth | Returns |
|---|---|---|---|
| 1 | `GET /un/secure/config/partner/languages` | None (called before login) | The language list, with `last_updated` for each language |
| 2 | `GET /un/secure/config/partner/languages/{locale_code}/content` | Optional. A token adds the partner-specific parts. | One JSON with everything for that language: UI strings, onboarding media, e-sign video, WhatsApp group and, when logged in, the experiment content the backend resolved |

There are no other language endpoints. There are no separate string files on the CDN (the strings come inside API 2), and the app no longer evaluates GrowthBook for content (section 5).

### What API 2 contains, and which language each part follows

| Part | Keyed by | Needs token |
|---|---|---|
| `strings` (UI text) | App language (`{locale_code}` in the URL) | No |
| `onboarding_media` | App language | No |
| `content_media` (e-sign video) | Partner's primary speaking language (from profile) | Yes |
| `whatsapp_group` | Primary speaking language | Yes |
| `experiments` (journey, intro, OneScore, sample audio) | Resolved variant, then the partner's language (section 5) | Yes |

Without a token, the backend returns only `strings` and `onboarding_media` for `{locale_code}`. With a token, it also fills in the speaking-language and experiment parts from the partner's profile.

## 2. Caching and refresh with `last_updated`

**App behaviour:**

1. On every app open, the app calls API 1 and caches the list. If the call fails, it uses the cached list.
2. For the selected app language, the app compares `last_updated` from the list with `last_updated` in its cached content:
   - If there's no cache, or the list value is newer, it calls API 2, saves the result and applies it.
   - If they're equal, it uses the cache and skips the download.
3. Right after login, the app calls API 2 once with the token, so the partner-specific parts get filled in. After that, the same `last_updated` rule applies.
4. When the app language or speaking language changes, the app calls API 2 again, unless the cache for that combination is already current.
5. English strings are bundled in the app, so any missing key shows in English. If there's no content at all (first launch while offline), the app shows English with the Hindi media.

**Backend rules for `last_updated`:**

- It's an ISO-8601 UTC timestamp, and it must be the same value in API 1 and API 2 for the same response.
- Bump it whenever anything in that language's content changes: a string, a media URL, a WhatsApp link, or experiment content.
- For logged-in calls, the value in API 1 must also reflect partner-specific changes: the partner's experiment assignment, or their primary speaking language changing. The backend returns the later of the language's content time and the partner's change time. This means API 1 should also accept an optional token and personalise `last_updated` when it's present.
- If exposing it in API 1 isn't possible, API 2 must support `If-Modified-Since` and return `304 Not Modified`. Otherwise the app has to download the full JSON every time.

## 3. Accept any language code everywhere

- `PUT /onboarding/update` (`first_language`, `second_language`) and `POST /girl/secure/profile/language/update` must accept any `code` from API 1, not a fixed list.
- The profile must return `primary_language` / `secondary_language` exactly as saved. The app currently compares them in lowercase and in title case (`"tamil"`, `"Tamil"`), so please keep one canonical format.
- **New:** save the app language on the backend. Add `app_language` (the `locale_code`) to `PUT /onboarding/update` and return it in the profile. That way it survives a reinstall and the backend can localize pushes. The app sends it today in the model, but it's dropped from the request.
- The `?appLanguage=<value>` deeplink should use `locale_code` (e.g. `ta`), not the display name (`Tamil`). The app will accept both during the transition.

## 4. Hardcoded content the backend now owns

Everything below is hardcoded in the app today and moves into API 2. For day one, the backend should copy the current URLs as they are, so behaviour doesn't change.

**By app language (onboarding, before the speaking language is known), in `onboarding_media`:**

| Content | Today |
|---|---|
| Meeting-1 intro video | One URL each for Hindi, Tamil, Telugu |
| Face-verification testimonial video | One URL each for Hindi, Tamil, Telugu |
| Agreement / e-sign explainer (onboarding) | One URL each for Hindi, Tamil, Telugu |
| "About VoiceClub" video | Same URL for all three |
| Onboarding question videos (name, language, marital status, education, religion; Telugu also has age and PAN) | One set each for Hindi, Tamil, Telugu |

**By primary speaking language, in `content_media` and `whatsapp_group`:**

| Content | Today |
|---|---|
| Aadhaar e-sign video (HyperVerge flow) | Hindi, Tamil, Telugu |
| WhatsApp community group | Tamil link, Hindi link, hidden for Telugu |

**By experiment and language, in `experiments` (section 5):**

| Content | Today |
|---|---|
| Journey: lessons, quizzes, showcase flows | `journeychanges`, evaluated in the app |
| Intro audio/video (probation or AI automation) | Tamil vs Hindi, with the automation variant chosen by `introaudio` in the app |
| Telugu skips the intro video | Hardcoded in the app |
| OneScore demo videos (30-min reward, avg call new, avg call old, chat received, online duration) | Tamil vs Hindi |
| Sample audio | `sampleaudio`, evaluated in the app |

**UI strings, in `strings`:** Tamil (about 100 keys) and the disabled Hindi file exist in the app today. The app team supplies them plus the English source for translators. Telugu has no strings yet, so it needs a translation pass. The key set is partner-specific and isn't shared with the customer app.

## 5. Server-evaluated experiments: backend evaluates GrowthBook, app renders

### 5.1 The change

Today the app evaluates several GrowthBook flags itself and then picks content by language. Examples: the journey (`journeychanges`), the intro audio script and video (`introaudio`), the sample audio (`sampleaudio`), and the Tamil vs Hindi OneScore demo videos.

After this change, **the backend evaluates these flags** with the partner's attributes, resolves the variant, picks the content for the partner's language, and returns it in API 2 under `experiments`. **The app only renders what it gets.** It has no flag logic and no language branching for this content.

A new language or a new variant then needs only a backend and GrowthBook change.

### 5.2 Flags in scope

| Flag | What the app does today | After |
|---|---|---|
| `journeychanges` | Reads `is_new_journey`, `penalty_allowed` and `stages` (lesson titles and URLs, MCQ/DEMO quiz questions, showcase flow titles and videos). It also decides the bottom tabs, the eligibility screen and auth routing from `is_new_journey` and whether stages exist. | `experiments.journey`, already resolved and translated |
| `linearonescorevariant` | Defined in the app but **never read**. OneScore demo videos are hardcoded Tamil vs Hindi. The live metrics screen already gets `video_url` from the metrics API. | `experiments.onescore`: the variant plus demo videos in the partner's language. The metrics API keeps returning a `video_url` that's correct for the variant and the language. |
| `introaudio` | Fetches all scripts, matches by language (falling back to the first), picks a random variant, and fills `{name}` / `{city}`. The intro video is Tamil vs Hindi, with an automation variant. The Telugu skip is hardcoded. | `experiments.intro`: the script for the partner's language, the resolved video URL, whether it's the automation variant, and the skip flag. The app still picks a random variant and fills in `{name}` / `{city}`. |
| `sampleaudio` | String URL with a hardcoded fallback | `experiments.sample_audio_url` for the partner's language |

**These stay in the app for now,** because they're pure on/off switches with no language content: `gooduserchattab`, `newkycflow`, `penaltywithdrawalexperiment`, `partnerdailychatreceivedcutoffreward`, `separatechatrewardvariants`, `xappkey`, and the onboarding `idto` flag.

**Later candidates** with user-visible text: `surveypartner` (question text) and `stickers`. They can move into `experiments` the same way when needed.

### 5.3 Evaluation rules

- **Attributes to evaluate with:** the ones the app sends to GrowthBook today, taken from the profile: `id`, `userId`, `language` (primary speaking language), `secondaryLanguage`, `partnerStatus`, `oneScore` and `onboardingDate`. Also add the new `appLanguage` (`locale_code`).
- **Which language the content uses:**
  - Journey text and videos: the app language, then the primary speaking language, then Hindi.
  - Intro, OneScore and sample audio: the primary speaking language, then Hindi.
- **Stable assignment:** evaluate with the same `id`, so a partner doesn't switch variants between calls.
- **Exposure tracking:** the backend records GrowthBook exposures. It also returns `experiments.assignments` (flag key to variation key), which the app forwards to Mixpanel in place of today's "enabled features with values" super property.
- **Shapes:** `journey` and `intro.script` keep exactly the JSON shape of today's GrowthBook values, including the existing camelCase keys like `lessonUrl`, `mcqQuestions` and `videoUrl`. That lets the app reuse its existing models.
- **Freshness:** when a partner's assignment or attributes change in a way that changes their content, bump their `last_updated` (section 2).

### 5.4 Reward audio (rewards API, no new endpoint)

The rewards API already returns `reward_audios: [{ language, audio_url }]`. Please return **only the entry for the partner's primary speaking language**, falling back to Hindi. The app will play the first entry, and the Tamil vs "first non-Tamil" logic goes away.

### 5.5 GrowthBook attributes and analytics

- The onboarding GrowthBook (still client-side, before login) sends `appLanguage` as the enum name (`"Hindi"`) today. It will switch to `locale_code` (`"hi"`). Please update targeting rules.
- The main-app attributes `language` and `secondaryLanguage` are unchanged.
- The Mixpanel people property `appLanguage` switches to `locale_code`.

## 6. Out of scope

- Push notification sounds and channels aren't language-specific in the partner app, so nothing changes.
- No Firebase topics depend on language in the partner app.
- Fonts: the app bundles no Indic fonts and relies on system fonts. A new script with poor system support would need an app release.

## 7. Adding or updating a language (runbook after this ships)

**New language:**

1. Add a row to API 1: `code`, `locale_code`, `description`, `icon`, `is_app_language`, `is_speaking_language` and `sort_order`.
2. Publish its API 2 content:
   - `strings`
   - `onboarding_media`
   - `content_media`
   - `whatsapp_group`
   - The experiment content for each variant: journey text and videos, intro script and video, OneScore demo videos and sample audio.

   Anything left out falls back to English strings or the Hindi media.
3. Add a reward audio entry for the language.
4. Set `last_updated`.
5. Make sure the customer app uses the same `code`, so call matching works.

**Updating a language:** change the content and bump `last_updated`. Apps pick it up on their next open.

## 8. Response structures

All keys are snake_case, except inside `journey` and `intro.script`, which keep today's shapes.

### 8.1 API 1: `GET /un/secure/config/partner/languages`

```json
{
  "languages": [
    {
      "code": "Hindi",
      "locale_code": "hi",
      "description": "हिन्दी",
      "icon": "https://vc-cdn.capslockmarketplaces.com/languages/hin_language.svg",
      "color": "#FF7A00",
      "is_app_language": true,
      "is_speaking_language": true,
      "sort_order": 1,
      "last_updated": "2026-09-23T10:30:00Z"
    },
    {
      "code": "Tamil",
      "locale_code": "ta",
      "description": "தமிழ்",
      "icon": "https://vc-cdn.capslockmarketplaces.com/languages/ta_language.svg",
      "color": "#8E44AD",
      "is_app_language": true,
      "is_speaking_language": true,
      "sort_order": 2,
      "last_updated": "2026-09-23T11:05:00Z"
    },
    {
      "code": "Telugu",
      "locale_code": "te",
      "description": "తెలుగు",
      "icon": "https://vc-cdn.capslockmarketplaces.com/languages/te_language.svg",
      "color": "#27AE60",
      "is_app_language": true,
      "is_speaking_language": true,
      "sort_order": 3,
      "last_updated": "2026-09-20T08:00:00Z"
    },
    {
      "code": "Bengali",
      "locale_code": "bn",
      "description": "বাংলা",
      "icon": null,
      "color": null,
      "is_app_language": false,
      "is_speaking_language": true,
      "sort_order": 4,
      "last_updated": null
    }
  ]
}
```

Bengali here is a speaking-only language. It's listed in the onboarding question but not offered as an app language, and `last_updated: null` means it has no content yet, so the app uses English strings and the Hindi media.

**Field rules**

| Field | Required | If missing or null |
|---|---|---|
| `code`, `locale_code` | Yes | Row is ignored. |
| `description` | Yes | `code` is shown. |
| `icon` | No | Picker shows the name only. |
| `is_app_language` / `is_speaking_language` | No | Treated as `false` / `true`. |
| `sort_order` | No | API order is used. |
| `last_updated` | No | No content for this language. English strings and Hindi media are used, and API 2 isn't called. |

### 8.2 API 2: `GET /un/secure/config/partner/languages/{locale_code}/content`

Example for `ta`, called **with** a token. The partner's primary speaking language is Tamil, and they're in the new journey, the linear OneScore variant and the automation intro.

```json
{
  "locale_code": "ta",
  "speaking_language": "Tamil",
  "last_updated": "2026-09-23T11:05:00Z",

  "strings": {
    "chooseLanguage": "மொழியைத் தேர்ந்தெடுக்கவும்",
    "continueText": "தொடரவும்",
    "watchGuidelinesVideo": "வழிகாட்டுதல்களைப் புரிந்துகொள்ள வீடியோவைப் பாருங்கள்",
    "welcomeUser": "வணக்கம் @name"
  },

  "onboarding_media": {
    "meeting_one_video_url": "https://…/ta/meeting1.mp4",
    "testimonial_video_url": "https://…/ta/testimonial.mp4",
    "agreement_video_url": "https://…/ta/agreement.mp4",
    "about_voiceclub_video_url": "https://…/about-vid.mp4",
    "question_videos": {
      "name": "https://…/ta/q_name.mp4",
      "language": "https://…/ta/q_language.mp4",
      "marital_status": "https://…/ta/q_marital.mp4",
      "education": "https://…/ta/q_education.mp4",
      "religion": "https://…/ta/q_religion.mp4",
      "age": null,
      "pan": null
    }
  },

  "content_media": {
    "esign_video_url": "https://vc-cdn.capslockmarketplaces.com/Aadhar_Esign_Tamil.mp4"
  },

  "whatsapp_group": {
    "enabled": true,
    "url": "https://chat.whatsapp.com/…tamil…"
  },

  "experiments": {
    "assignments": {
      "journeychanges": "new_journey",
      "linearonescorevariant": "linear",
      "introaudio": "automation"
    },

    "journey": {
      "is_new_journey": true,
      "penalty_allowed": false,
      "stages": [
        {
          "id": 1,
          "stage": "S1",
          "lessons": [
            { "id": 11, "title": "வாய்ஸ் கிளப் என்றால் என்ன?", "lessonUrl": "https://…/ta/s1_lesson1.mp4" }
          ],
          "quiz": {
            "type": "MCQ",
            "mcqQuestions": ["…same shape as today's journeychanges, text in Tamil…"]
          },
          "flows": [
            { "id": 1, "title": ["முதல் படி", "இரண்டாம் படி"], "videoUrl": "https://…/ta/showcase_1.mp4" }
          ]
        }
      ]
    },

    "intro": {
      "skip_intro_video": false,
      "is_automation": true,
      "video_url": "https://vc-cdn.capslockmarketplaces.com/Tamil-ai-intro-audio-video.mp4",
      "script": {
        "language": "Tamil",
        "prompt": "…",
        "variants": [
          {
            "primary_variant": "வணக்கம், நான் {name}, {city}-லிருந்து பேசுகிறேன்…",
            "secondary_variant": "…",
            "audio_url": "https://…/ta/intro_variant_1.mp3"
          }
        ]
      }
    },

    "onescore": {
      "variant": "linear",
      "demo_videos": {
        "reward_30_mins": "https://…/ta/30mins.mp4",
        "avg_call_new": "https://…/ta/avg_call_new.mp4",
        "avg_call_old": "https://…/ta/avg_call_old.mp4",
        "chat_received": "https://…/ta/chat_received.mp4",
        "online_duration": "https://…/ta/online_duration.mp4"
      }
    },

    "sample_audio_url": "https://…/ta/sample_audio.mp3"
  }
}
```

Called **without** a token (before login), the same URL returns only `locale_code`, `last_updated`, `strings` and `onboarding_media`. `content_media`, `whatsapp_group` and `experiments` are `null`.

A logged-in Telugu partner who isn't in any experiment would get:

- `strings: {}` (no Telugu translations yet, so the app shows English)
- `whatsapp_group: { "enabled": false, "url": null }`
- `experiments.assignments: {}`
- `experiments.journey: null`
- `experiments.intro: { "skip_intro_video": true, "is_automation": false, "video_url": null, "script": null }`
- Hindi fallbacks wherever Telugu content doesn't exist

**Field rules**

| Field | If missing or null |
|---|---|
| `last_updated` | Treated as changed, so the app re-downloads on the next open. |
| `strings`, or any key in it | Bundled English is used. Placeholders use `@param`, and the names must match English exactly. Keys starting with `@` are ignored. |
| `onboarding_media.*` | Hindi URL is used. |
| `question_videos.age`, `question_videos.pan` | That question is shown without a video. |
| `content_media.esign_video_url` | Hindi e-sign video is used. |
| `whatsapp_group` | Hindi group is shown. |
| `whatsapp_group.enabled` = `false` | The WhatsApp sheet isn't shown (today's Telugu rule). |
| `experiments` (no token) | Not applied. The app waits for the logged-in call. |
| `experiments.assignments` | Nothing is forwarded to Mixpanel. |
| `experiments.journey` | Treated as "no journey config", which is today's behaviour when `journeychanges` is off. |
| `experiments.journey.is_new_journey` | `false`, so the legacy lesson/quiz tutorial runs if `stages` exist. |
| `experiments.intro` | No intro video and no intro script. |
| `experiments.intro.script` | The intro recording screen shows no script, which is today's behaviour when `introaudio` is off. |
| `experiments.onescore.demo_videos.*` | That demo video's button is hidden. |
| `experiments.sample_audio_url` | The app's bundled default sample audio is used. |

### 8.3 Onboarding and profile (existing APIs)

`PUT /onboarding/update`. Only `app_language` is new.

```json
{
  "first_language": "Tamil",
  "second_language": "Kannada",
  "app_language": "ta"
}
```

Profile response. Only `app_language` is new.

```json
{
  "primary_language": "Tamil",
  "secondary_language": "Kannada",
  "app_language": "ta"
}
```

`POST /girl/secure/profile/language/update` has no shape change, and it must accept any `code`.

### 8.4 Rewards API (existing)

No shape change. Return only the entry for the partner's primary speaking language, falling back to Hindi.

```json
{
  "id": 42,
  "name": "…",
  "reward_audios": [
    { "language": "Tamil", "audio_url": "https://…/reward_tamil.mp3" }
  ]
}
```

### 8.5 Metrics API (existing, live OneScore)

No shape change. `aggregate.video_url` must be correct for both the partner's `linearonescorevariant` variant and their primary speaking language.

### 8.6 GrowthBook attributes

| Item | Value |
|---|---|
| Onboarding attribute `appLanguage` (client-side, before login) | Changes from `"Tamil"` to `"ta"` |
| Main-app attributes `language`, `secondaryLanguage` | No change (speaking `code`) |
| Server-side evaluation attributes (API 2) | `id`, `userId`, `language`, `secondaryLanguage`, `partnerStatus`, `oneScore`, `onboardingDate`, `appLanguage` |

## Open questions for the backend lead

1. Can API 1 take an optional token and return a personalised `last_updated` (recommended)? If not, will API 2 support `If-Modified-Since` / `304`?
2. Is `code` the same value in the customer and partner apps (for example, both `"Tamil"`)? Call matching depends on it.
3. Who owns partner translations, and how are `strings` published (admin panel, file upload)?
4. Are the onboarding question videos managed anywhere today (CMS, GrowthBook), or only in the app? If only in the app, the backend needs a place to store them per language.
5. Should the app language be stored on the backend (recommended, for reinstalls and push localization)?
6. Does the backend already run a GrowthBook server SDK, or does it need to be added for API 2? Who owns exposure logging once evaluation moves to the server?
7. Beyond the score and video, what does `linearonescorevariant` change for the partner (labels, explanations, thresholds)? Any user-visible text for it should come translated inside `experiments.onescore`. Please list those fields so we can add them to 8.2.
8. Should `journey` text follow the app language or the primary speaking language? This doc proposes the app language first, then the speaking language, then Hindi.
9. What's the expected size of `strings`? It's about 100 keys today and will grow as hardcoded strings are moved over. Please enable gzip on API 2.
